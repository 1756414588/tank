package com.account.plat.impl.chQzHjdgAppstore;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.Date;
import java.util.HashMap;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class ChQzHjdgAppstorePlat extends PlatBase {
    private final static String LOGIN_STATUS_KEY = "status";
    private final static String LOGIN_STATUS_VALUE_SUCCESS = "1";
    private final static String LOGIN_STATUS_VALUE_ERROR = "10";
    private final static String LOGIN_STATUS_VALUE_NOLOGIN = "11";

    private static String ServerUrl = "http://iossdk.ttshouyou.cn/cpVerify.php";

    private static String AppID = "10127";

    private static String AppKey;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chQzQmtkzzAppstore/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
        ServerUrl = properties.getProperty("ServerUrl");
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK; // GameError.INVALID_PARAM
    }

    public int getPlatNo() { //  角色与草花 仟指 IOS 红警世界互通
        return 555;
    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            LOG.error("GameError.PARAM_ERROR");
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();
        String[] vParam = sid.split("_");
        if (vParam.length < 3) {
            LOG.error("vParam.length:" + vParam.length);
            return GameError.PARAM_ERROR;
        }

        String uin = vParam[0];
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
            LOG.error("chQzHjdg_appstore 开始调用sidInfo接口");

            String username = URLEncoder.encode(param[0], "utf-8");
            String token = URLEncoder.encode(param[1], "utf-8");
            String id = param[2];

            JSONObject obj = new JSONObject();
            obj.put("id", id);
            obj.put("appid", AppID);
            obj.put("username", username);
            obj.put("token", token);
            String postbody = obj.toString();
            // String postbody = "id=" + id + "&appid=" + AppID + "&username=" + username + "&token=" + token;
            // String postbody = "{ id : " + id + ", appid : " + AppID + ", username : " + username + ", token : " + token + " }";
            LOG.error("参数结果：" + postbody);
            LOG.error("[请求url]" + ServerUrl);

            HashMap<String, String> map = new HashMap<String, String>();
            // 设置文件字符集:
            map.put("Charset", "UTF-8");
            // 设置文件类型:
            map.put("Content-Type", "application/json");
            String result = HttpUtils.sendJsonPost(ServerUrl, postbody);

            LOG.error("[响应结果]" + result);

            JSONObject object = JSONObject.fromObject(result);
            String status = object.get(LOGIN_STATUS_KEY).toString();
            LOG.error(status);
            if (LOGIN_STATUS_VALUE_SUCCESS.equals(status)) {
                LOG.error("chQzHjdg_appstore登陆成功 ");
                return true;
            } else if (LOGIN_STATUS_VALUE_NOLOGIN.equals(status)) {
                LOG.error("chQzHjdg_appstore登陆失败,用户未登录:" + result);
                return false;
            } else if (LOGIN_STATUS_VALUE_ERROR.equals(status)) {
                LOG.error("chQzHjdg_appstore登陆失败,参数错误:" + result);
                return false;
            } else {
                LOG.error("chQzHjdg_appstore登陆失败,未知错误:" + result);
                return false;
            }
        } catch (Exception e) {
            LOG.error("chQzHjdg_appstore 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }
    }

    // public static void main(String[] args) {
    //
    // String[] param= {"0348BA885EDF4F62","4ff036a13254eafe","4ff036a13254eafe","selfServer1503022834688"};
    //
    // String AppID="0348BA885EDF4F62";
    //
    // String AppKey="7UO9WFQACAZVQXXMYK9IJWX43ANG6F8X";
    //
    // String ServerUrl="http://sync.1sdk.cn/login/check.html";
    //
    // String app =param[0];
    // String sdk = param[1];
    // String uin = null ;
    // String sess = null;
    //
    // try {
    // uin = URLEncoder.encode(param[2],"utf-8");
    // sess = URLEncoder.encode(param[3],"utf-8");
    //
    // } catch (UnsupportedEncodingException e1) {
    //
    //
    // e1.printStackTrace();
    // }
    //
    // LOG.error(app + sdk + uin + sess);
    //
    // String url = ServerUrl + "?AppID=" + AppID + "&sdk="+ sdk+"&app="+app +"&uin="+ uin +"&sess="+ sess
    // +"&AppKey="+AppKey;
    //
    // LOG.error("[请求url]" + url);
    //
    // String result = HttpUtils.sendGet(url,new HashMap<String, String>());
    //
    // LOG.error("[响应结果]" + result);
    //
    //
    // }

    final String[] PAY_BACK_PARAM = {"orderid", "username", "appid", "roleid", "serverid", "amount", "paytime",
            "attach", "productname", "appkey"};

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error(" chQzHjdg_appstore payBack开始");
        try {

            String orderid = URLDecoder.decode(request.getParameter(PAY_BACK_PARAM[0]), "UTF-8");
            String username = URLDecoder.decode(request.getParameter(PAY_BACK_PARAM[1]), "UTF-8");
            String appid = URLDecoder.decode(request.getParameter(PAY_BACK_PARAM[2]), "UTF-8");
            String roleid = URLDecoder.decode(request.getParameter(PAY_BACK_PARAM[3]), "UTF-8");
            String serverid = URLDecoder.decode(request.getParameter(PAY_BACK_PARAM[4]), "UTF-8");
            String amount = URLDecoder.decode(request.getParameter(PAY_BACK_PARAM[5]), "UTF-8");
            String paytime = URLDecoder.decode(request.getParameter(PAY_BACK_PARAM[6]), "UTF-8");
            String attach = URLDecoder.decode(request.getParameter(PAY_BACK_PARAM[7]), "UTF-8");
            String productname = URLDecoder.decode(request.getParameter(PAY_BACK_PARAM[8]), "UTF-8");

            HashMap<String, String> params = new HashMap<>();
            params.put("orderid", orderid);
            params.put("username", URLEncoder.encode(username, "UTF-8"));
            params.put("appid", appid);
            params.put("roleid", URLEncoder.encode(roleid, "UTF-8"));
            params.put("serverid", URLEncoder.encode(serverid, "UTF-8"));
            params.put("amount", amount);
            params.put("paytime", paytime);
            params.put("attach", attach);
            params.put("productname", URLEncoder.encode(productname, "UTF-8"));
            params.put("appkey", AppKey);//将支付秘钥加入

            // 组装签名必须要照需求文档的加密规则来执行，就是上面渠道商发过来的参数+PayKEY组成sign和渠道商发过来的sign做比较
            StringBuffer sb = new StringBuffer();
            for (int i = 0; i < PAY_BACK_PARAM.length; i++) {
                // 同list进行遍历
                // 获取key值
                String k = PAY_BACK_PARAM[i];
                // 获取对应的value
                String v = params.get(k);
                sb.append(k + "=" + v + "&");
            }

            sb.deleteCharAt(sb.length() - 1);
            String signstr = sb.toString();

            // 调用MD5进行签名
            String checkSign = MD5.md5Digest(signstr);

            String sign = URLDecoder.decode(request.getParameter("sign"), "UTF-8");

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
                // 渠道订单号
                payInfo.orderId = orderid;
                // 付费金额
                payInfo.amount = Integer.valueOf(amount);

                String[] param = attach.split("_");
                serverid = param[0];
                roleid = param[1];
                String mills = param[2];
                String platId = param[4];

                // 游戏内部订单号
                payInfo.serialId = serverid + roleid + mills + payInfo.amount;
                // 渠道id
                payInfo.platId = platId;
                // 游戏区号
                payInfo.serverId = Integer.valueOf(serverid);
                // 玩家角色id
                payInfo.roleId = Long.valueOf(roleid);


                int code = payToGameServer(payInfo);

                if (code != 0) {
                    LOG.error("chQzHjdg_appstore 充值发货失败！！ " + code);
                }
                return "success";

            } else {
                // afNewMjdzh1_appstore 签名不一致！！ 2c461a02105b45922989a515017aa7f0|286cfafa5a9324f2a80518b60a205b6e
                LOG.error("chQzHjdg_appstore 签名不一致！！ " + checkSign + "|" + sign);
                return "errorSign";
            }
        } catch (Exception e) {
            LOG.error("chQzHjdg_appstore 充值异常！！ " + e.getMessage());
            e.printStackTrace();
            return "error";
        }
    }
}
