package com.account.plat.impl.chYhYijie1;


import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.*;

@Component
public class ChYhYijie1Plat extends PlatBase {

    private static String ServerUrl = "";

    private static String AppID;

    private static String AppKey;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties(
                "com/account/plat/impl/chYhYijie1/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
        ServerUrl = properties.getProperty("ServerUrl");
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK; //GameError.INVALID_PARAM

    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {


        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion()
                || !req.hasDeviceNo()) {
            LOG.error("chYhYijie1 GameError.PARAM_ERROR");
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();
        String[] vParam = sid.split("__");
        if (vParam.length < 4) {
            LOG.error("vParam.length" + vParam.length);
            return GameError.PARAM_ERROR;
        }


        // String sdk = vParam[0];
        // String app = vParam[1];
        String uin = vParam[2];
        String sess = vParam[3];
        //	 channelId==sdk   appid=app     userId=uin   token=sess
        boolean backboolean = verifyAccount(vParam);
        if (!backboolean) {
            LOG.error("GameError.SDK_LOGIN" + GameError.SDK_LOGIN);
            return GameError.SDK_LOGIN;
        }


        Account account = accountDao.selectByPlatId(getPlatNo(), uin);


        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();

            account.setPlatNo(this.getPlatNo());
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
            LOG.error("chYhYijie1 开始调用sidInfo接口");

            String app = param[0];
            String sdk = param[1];
            String uin = URLEncoder.encode(param[2], "utf-8");
            String sess = URLEncoder.encode(param[3], "utf-8");

            LOG.error("参数结果：" + sdk + "_" + app + "_" + uin + "_" + sess);

            String url = ServerUrl + "?AppID=" + AppID + "&sdk=" + sdk + "&app=" + app + "&uin=" + uin + "&sess=" + sess + "&AppKey=" + AppKey;

            LOG.error("[请求url]" + url);

            String result = HttpUtils.sendGet(url, new HashMap<String, String>());

            LOG.error("[响应结果]" + result);

            if ("0".equals(result)) {
                LOG.error("chYhYijie1登陆成功");
                return true;
            } else {
                LOG.error("chYhYijie1登陆失败:" + result);
                return false;
            }
        } catch (Exception e) {
            LOG.error("chYhYijie1 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }
    }


    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("payBack开始");
        try {
            Map<String, String> params = new HashMap<String, String>();
            String app = URLDecoder.decode(request.getParameter("app"), "UTF-8");
            String cbi = URLDecoder.decode(request.getParameter("cbi"), "UTF-8");
            String ct = URLDecoder.decode(request.getParameter("ct"), "UTF-8");
            String fee = URLDecoder.decode(request.getParameter("fee"), "UTF-8");
            String pt = URLDecoder.decode(request.getParameter("pt"), "UTF-8");
            String sdk = URLDecoder.decode(request.getParameter("sdk"), "UTF-8");
            String ssid = URLDecoder.decode(request.getParameter("ssid"), "UTF-8");
            String st = URLDecoder.decode(request.getParameter("st"), "UTF-8");
            String tcd = URLDecoder.decode(request.getParameter("tcd"), "UTF-8");
            String uid = URLDecoder.decode(request.getParameter("uid"), "UTF-8");
            String ver = URLDecoder.decode(request.getParameter("ver"), "UTF-8");
            String sign = URLDecoder.decode(request.getParameter("sign"), "UTF-8");

            params.put("app", app);
            params.put("cbi", cbi);
            params.put("ct", ct);
            params.put("fee", fee);
            params.put("pt", pt);
            params.put("sdk", sdk);
            params.put("ssid", ssid);
            params.put("st", st);
            params.put("tcd", tcd);
            params.put("uid", uid);
            params.put("ver", ver);
            params.put("sign", sign);


            // 组装签名必须要照需求文档的加密规则来执行，就是上面渠道商发过来的参数+PayKEY组成sign和渠道商发过来的sign做比较
            // 排序key值
            // 把params的key值全部获取并赋值给一个新的list
            List<String> keys = new ArrayList<String>(params.keySet());
            // 对List进行排序
            Collections.sort(keys);

            LOG.error("keys:" + keys);//[app, cbi, ct, fee, pt, sdk, sign, ssid, st, tcd, uid, ver]

            LOG.error("params" + params);//{sign=286cfafa5a9324f2a80518b60a205b6e, uid=1142791, fee=1000, app=0348ba885edf4f62, pt=1503383479450, ssid=38780360, ver=1, st=1, sdk=b101363ca00933d2, tcd=565efae8545a435aadc7f47ffcbfc2e1, cbi=1_65405259_1503383479569_B101363CA00933D2, ct=1503383500000}

            StringBuilder sb = new StringBuilder();

            LOG.error("st:" + st);

            if (!"1".equals(st)) {
                return "ERROR";
            }

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
            signstr = signstr + AppKey;
            // 对signstr进行编码
            //signstr = URLDecoder.decode(signstr, "UTF-8");
            // 调用MD5进行签名
            String checkSign = MD5.md5Digest(signstr);
            // 打印参数名和对应的参数值
            LOG.error("signstr:" + signstr);//signstr:app=0348ba885edf4f62&cbi=1_65405259_1503383479569_B101363CA00933D2&ct=1503383500000&fee=1000&pt=1503383479450&sdk=b101363ca00933d2&ssid=38780360&st=1&tcd=565efae8545a435aadc7f47ffcbfc2e1&uid=1142791&ver=1&AppKey=7UO9WFQACAZVQXXMYK9IJWX43ANG6F8X

            LOG.error("sign:" + sign);//sign:286cfafa5a9324f2a80518b60a205b6e

            if (sign.equalsIgnoreCase(checkSign)) {
//				
//				platNo 游戏内部渠道号 platId 渠道用户id orderId 渠道订单号 serialId 游戏内部订单号
//				 *               serverId 游戏区号 roleId 玩家角色id amount 付费金额（国内单位是元，国外暂定）
//				
                PayInfo payInfo = new PayInfo();
                //游戏内部渠道号
                payInfo.platNo = getPlatNo();

                //渠道用户id
                payInfo.platId = sdk;

                String orderId = tcd;
                //渠道订单号

                payInfo.orderId = orderId;


                //游戏内部订单号
                payInfo.serialId = cbi;
                String[] s = cbi.split("_");

                //游戏区号
                payInfo.serverId = Integer.valueOf(s[0]);

                //玩家角色id
                payInfo.roleId = Long.valueOf(s[1]);

                //付费金额
                int amount = Integer.valueOf(fee);

                payInfo.amount = amount / 100;

                int code = payToGameServer(payInfo);

                if (code != 0) {
                    LOG.error("chYhYijie1 充值发货失败！！ " + code);
                }
                return "SUCCESS";

            } else {
                LOG.error("chYhYijie1 签名不一致！！ " + checkSign + "|" + sign);
                return "ERROR";
            }
        } catch (Exception e) {
            LOG.error("chYhYijie1 充值异常！！ " + e.getMessage());
            e.printStackTrace();
            return "ERROR";
        }
    }


}
