package com.account.plat.impl.caohuaEnAppstore;

import com.account.constant.GameError;
import com.account.dao.impl.PayDao;
import com.account.domain.Account;
import com.account.domain.Pay;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import net.sf.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.net.URLEncoder;
import java.util.*;

@Component
public class CaoHuaEnAppstorePlat extends PlatBase {

    @Autowired
    protected PayDao payDao;

    private static String ServerUrl = "";

    private static String serverKey;

    private static String AppKey;

    private static String AppId;

//	private static Map<Integer, String> RECHARGE_MAP = new HashMap<Integer, String>();

    //KEY:订单金额(美元),VALUE:充值金额(人民币)
    private static Map<Integer, Integer> moneyMap = new HashMap<Integer, Integer>();

    @PostConstruct
    public void init() {
        Properties properties = loadProperties(
                "com/account/plat/impl/caohuaEnAppstore/", "plat.properties");
        serverKey = properties.getProperty("serverKey");
        AppKey = properties.getProperty("AppKey");
        ServerUrl = properties.getProperty("ServerUrl");
        AppId = properties.getProperty("AppId");
        LOG.error("init()");
        initRechargeMap();
    }

    private void initRechargeMap() {
        moneyMap.put(1, 6);
        moneyMap.put(5, 30);
        moneyMap.put(10, 68);
        moneyMap.put(20, 128);
        moneyMap.put(50, 328);
        moneyMap.put(100, 648);
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;

    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        LOG.error("doLogin开始1");

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion()
                || !req.hasDeviceNo()) {
            LOG.error("GameError.PARAM_ERROR");
            return GameError.PARAM_ERROR;
        }
        LOG.error("doLogin开始2");
        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();
        LOG.error("doLogin开始3");
        String[] vParam = sid.split("_");
        if (vParam.length != 2) {
            LOG.error("vParam.length:" + vParam.length);
            return GameError.PARAM_ERROR;
        }

        String uin = vParam[0];

        boolean backboolean = verifyAccount(vParam);
        if (!backboolean) {
            LOG.error("GameError.SDK_LOGIN");
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), uin);

        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();

            account.setPlatNo(this.getPlatNo());
            account.setChildNo(super.getPlatNo());
            account.setPlatId(uin);
            account.setAccount(getPlatNo() + "_" + uin);
            account.setPasswd(uin);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setToken(token);
            account.setDeviceNo(deviceNo);
            Date now = new Date();
            account.setLoginDate(now);
            account.setCreateDate(now);
            accountDao.insertWithAccount(account);

        } else {
            String token = RandomHelper.generateToken();
            account.setToken(token);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setDeviceNo(deviceNo);
            account.setLoginDate(new Date());
            accountDao.updateTokenAndVersion(account);

        }

        GameError authorityRs = super.checkAuthority(account);
        if (authorityRs != GameError.OK) {
            LOG.error("authorityRs:" + authorityRs);
            return authorityRs;
        }

        response.addAllRecent(super.getRecentServers(account));
        response.setKeyId(account.getKeyId());
        response.setToken(account.getToken());

        if (isActive(account)) {
            response.setActive(1);

        } else {
            response.setActive(0);

        }

        return GameError.OK;
    }

    private boolean verifyAccount(String[] param) {
        try {
            LOG.error("caohuaEn 开始调用sidInfo接口");

            int appid = Integer.valueOf(URLEncoder.encode(AppId, "utf-8"));
            int userid = Integer.valueOf(URLEncoder.encode(param[0], "utf-8"));
            int times = (int) System.currentTimeMillis();
            // String token= URLEncoder.encode(param[1],"utf-8");
            String token = param[1];
            LOG.error("param[1]:" + param[1]);
            LOG.error("token:" + token);

            LOG.error("参数结果：" + appid + "_" + userid + "_" + times
                    + "_" + token);

            String sign1 = "appid=" + appid + "&times=" + times + "&token="
                    + token + "&userid=" + userid + AppKey;

            String sign = MD5.md5Digest(sign1).toUpperCase();

            String data = "appid=" + appid + "&times=" + times + "&token="
                    + token + "&userid=" + userid + "&sign=" + sign;

            LOG.error("[请求url]" + ServerUrl);

            LOG.error("[sing1]" + sign1);

            LOG.error("[sing]" + sign);

            LOG.error("[data]" + data);

            String result = HttpUtils.sentPost(ServerUrl, data);

            LOG.error("[result]" + result);

            JSONObject rsp = JSONObject.fromObject(result);

            if (rsp.getInt("code") == 200) {
                LOG.error("msg" + rsp.getString("msg"));
                return true;
            } else if (rsp.getInt("code") == 201) {
                LOG.error("msg" + rsp.getString("msg"));
                return false;
            } else if (rsp.getInt("code") == 202) {
                LOG.error("msg" + rsp.getString("msg"));
                return false;
            } else {
                LOG.error("msg" + rsp.getString("msg"));
                return false;
            }
        } catch (Exception e) {
            LOG.error("caohuaEn 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }
    }

    @Override
    public String payBack(WebRequest request, String content,
                          HttpServletResponse response) {
        LOG.error("CaoHuaEnAppstorepayBack开始");
        try {
            Map<String, String> params = new HashMap<String, String>();

            LOG.error("获取参数开始");
            String orderno = request.getParameter("orderno");
            String orderno_cp = request.getParameter("orderno_cp");
            String userid = request.getParameter("userid");
            String order_amt = request.getParameter("order_amt");//订单金额
            String pay_amt = request.getParameter("pay_amt");//实际支付金额
            String pay_time = request.getParameter("pay_time");
            String extra = request.getParameter("extra");
            String sign = request.getParameter("sign");

            LOG.error("orderno:" + orderno);
            LOG.error("orderno_cp:" + orderno_cp);
            LOG.error("userid:" + userid);
            LOG.error("order_amt:" + order_amt);
            LOG.error("pay_amt:" + pay_amt);
            LOG.error("pay_time:" + pay_time);
            LOG.error("extra:" + extra);
            LOG.error("sign:" + sign);

            LOG.error("获取参数结束");
            LOG.error("添加map开始");
            params.put("orderno", orderno);
            params.put("orderno_cp", orderno_cp);
            params.put("userid", userid);
            params.put("order_amt", order_amt);
            params.put("pay_amt", pay_amt);
            params.put("pay_time", pay_time);
            params.put("extra", extra);
            LOG.error("添加map结束");
            // params.put("sign", sign);

            LOG.error("截取参数开始");
            String[] s = extra.split("_");

            LOG.error("s:" + s);
            LOG.error("s.length:" + s.length);

            LOG.error("截取参数结束");

            LOG.error("查询订单开始");
            int platNo = 195;

            Pay pay = payDao.selectPay(platNo, orderno);

            if (pay != null) {
                LOG.error("订单号已经存在");
                JSONObject rsp = new JSONObject();
                rsp.put("code", 200);
                rsp.put("msg", "订单号已经存在");
                rsp.put("data", "[]");
                String S = rsp.toString();
                return S;
            }
            // if(!order_amt.equals(pay_amt)){
            // LOG.error("订单金额和充值金额不一致");
            // return "{'code' : 203, 'msg':'订单金额和充值金额不一致', 'data' :[]}";
            // }

            LOG.error("查询订单结束");

            List<String> keys = new ArrayList<String>(params.keySet());

            Collections.sort(keys);

            LOG.error("keys:" + keys);

            LOG.error("params:" + params);

            StringBuilder sb = new StringBuilder();

            for (int i = 0; i < keys.size(); i++) {
                // 同list进行遍历
                // 获取key值
                String k = keys.get(i);
                // 获取对应的value
                String v = params.get(k);
                // 要排除掉不参入签名的参数（忽略大小写）
                if (!k.equalsIgnoreCase("sign")) {
                    sb.append(k + "=" + v + "&");
                }
            }
            //  删除最后一个字符 
            sb.deleteCharAt(sb.length() - 1);
            // 将StringBuilder转换为String
            String signstr = sb.toString();
            // 在String添加支付秘钥PayKEY
            signstr = signstr + serverKey;
            // 对signstr进行编码
            // signstr = URLDecoder.decode(signstr, "UTF-8");
            // 调用MD5进行签名
            String checkSign = MD5.md5Digest(signstr).toUpperCase();
            // 打印参数名和对应的参数值
            LOG.error("signstr:" + signstr);

            LOG.error("sign:" + sign);

            if (sign.equalsIgnoreCase(checkSign)) {
                //
                // platNo 游戏内部渠道号 platId 渠道用户id orderId 渠道订单号 serialId 游戏内部订单号
                // * serverId 游戏区号 roleId 玩家角色id amount 付费金额（国内单位是元，国外暂定）
                //
                PayInfo payInfo = new PayInfo();
                // 游戏内部渠道号
                payInfo.platNo = getPlatNo();
                payInfo.childNo = super.getPlatNo();

                // 渠道用户id
                payInfo.platId = userid;

                String orderId = orderno;
                // 渠道订单号

                payInfo.orderId = orderId;

                // 游戏内部订单号
                payInfo.serialId = extra;

                // 游戏区号
                payInfo.serverId = Integer.valueOf(s[0]);

                // 玩家角色id
                payInfo.roleId = Long.valueOf(s[1]);

                //充值金额
                payInfo.amount = moneyMap.get(Integer.parseInt(order_amt));
                //支付金额
                payInfo.realAmount = Double.parseDouble(pay_amt);

                int code = payToGameServer(payInfo);

                if (code != 0) {
                    LOG.error("caohuaEn_appstore 充值发货失败！！ " + code);
                }
                JSONObject rsp = new JSONObject();
                rsp.put("code", 200);
                rsp.put("msg", "充值成功");
                rsp.put("data", "[]");
                String S = rsp.toString();
                return S;

            } else {
                // caohuaEn_appstore 签名不一致！！
                // 2c461a02105b45922989a515017aa7f0|286cfafa5a9324f2a80518b60a205b6e
                LOG.error("caohuaEn_appstore 签名不一致！！ " + checkSign
                        + "|" + sign);
                JSONObject rsp = new JSONObject();
                rsp.put("code", 203);
                rsp.put("msg", "签名不一致");
                rsp.put("data", "[]");
                String S = rsp.toString();
                return S;

            }
        } catch (Exception e) {
            LOG.error("caohuaEn_appstore 充值异常！！ " + e.getMessage());
            e.printStackTrace();
            JSONObject rsp = new JSONObject();
            rsp.put("code", 203);
            rsp.put("msg", "充值异常");
            rsp.put("data", "[]");
            String S = rsp.toString();
            return S;
        }
    }

    // public static void main(String[] args) {
    // String S = "{'code' : 203, 'msg':'充值异常', 'data' :[]}";
    //
    // JSONObject json = JSONObject.fromObject(S);
    //
    // String s= json.getString("msg");
    //
    // LOG.error(s);
    //
    // }

}
