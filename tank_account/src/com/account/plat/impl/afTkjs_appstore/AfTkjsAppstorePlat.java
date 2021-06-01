package com.account.plat.impl.afTkjs_appstore;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.kaopu.MD5Util;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.net.URLDecoder;
import java.util.*;

class AnfanAccount {
    public String ucid;// id
    public String uid; // name
    public String phone;
    public String uuid; // 授权码
}

@Component
public class AfTkjsAppstorePlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";
    // 新sdk server的接口地址
    private static String new_serverUrl = "";

    private static String SIGN_KEY;
    private static String APP_SECRET;
    private static String APP_ID;
    private static String PAY_VERIRY_URL;
    static final String[] PAY_BACK_PARAMS = new String[]{"open_id", "body", "subject", "fee", "vid", "sn", "vorder_id", "create_time", "version"};


    private static Map<Integer, String> RECHARGE_MAP = new HashMap<Integer, String>();
    private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();

    public static String getSignKey() {
        return SIGN_KEY;
    }

    @Override
    public int getPlatNo() { // // 角色与anfan互通
        return 95;
    }

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/afTkjs_appstore/", "plat.properties");
        SIGN_KEY = properties.getProperty("SIGN_KEY");
        APP_SECRET = properties.getProperty("APP_SECRET");
        serverUrl = properties.getProperty("VERIRY_URL");
        new_serverUrl = properties.getProperty("NEW_VERIRY_URL");
        APP_ID = properties.getProperty("APP_ID");
        PAY_VERIRY_URL = properties.getProperty("PAY_VERIRY_URL");
        initRechargeMap();
    }

    private void initRechargeMap() {
        RECHARGE_MAP.put(1, "com.tank.jishi60");
        MONEY_MAP.put(1, 6);

        RECHARGE_MAP.put(2, "com.tank.jishi300");
        MONEY_MAP.put(2, 30);

        RECHARGE_MAP.put(3, "com.tank.jishi980");
        MONEY_MAP.put(3, 98);

        RECHARGE_MAP.put(4, "com.tank.jishi1980");
        MONEY_MAP.put(4, 198);

        RECHARGE_MAP.put(5, "com.tank.jishi3280");
        MONEY_MAP.put(5, 328);

        RECHARGE_MAP.put(6, "com.tank.jishi6480");
        MONEY_MAP.put(6, 648);
    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String[] vParam = sid.split("&");

        String userId = null;
        String uid = null;

        if (vParam.length == 3) {
            uid = vParam[0];
            String ucid = vParam[1];
            String uuid = vParam[2];
            AnfanAccount anfanAccount = verifyAccount(uid, ucid, uuid);
            if (anfanAccount == null) {
                return GameError.SDK_LOGIN;
            }

            userId = anfanAccount.ucid;
        }

        if (vParam.length == 2) {
            String openid = vParam[0];
            String token = vParam[1];

            if (!verifyAccount(openid, token)) {
                return GameError.SDK_LOGIN;
            }

            userId = openid;
            uid = openid;
        }

        if (userId == null) {
            LOG.error("afTkjs_appstore doLogin  userId is null");
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userId);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(userId);
            account.setAccount(getPlatNo() + "_" + userId);
            account.setPasswd(uid);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setToken(token);
            account.setDeviceNo(deviceNo);
            Date now = new Date();
            account.setLoginDate(now);
            account.setCreateDate(now);
            accountDao.insertWithAccount(account);
            response.setUserInfo("1");
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

    private boolean verifyAccount(String openid, String token) {
        try {
            LOG.error("afTkjs_appstore 开始调用sidInfo接口:" + new_serverUrl);

            String postdatasb = "app_id=" + APP_ID + "&open_id=" + openid + "&token=" + token + "&sign_key=" + SIGN_KEY;
            LOG.error("afTkjs_appstore 待签名字符串： " + postdatasb);
            // 对排序后的参数附加开发商签名密钥
            String sign = MD5Util.toMD5(postdatasb.toString());
            LOG.error("afTkjs_appstore 签名值：" + sign);

            String postdata = "app_id=" + APP_ID + "&open_id=" + openid + "&token=" + token + "&sign=" + sign;
            LOG.error("afTkjs_appstore 需要发送到服务器的数据为：" + postdata);

            String result = HttpUtils.sentPost(new_serverUrl, postdata);

            LOG.error("afTkjs_appstore 收到到服务器的数据为：" + result);

            JSONObject rsp = JSONObject.fromObject(result);
            if (!rsp.containsKey("code")) {
                return false;
            }

            int code = rsp.getInt("code");
            if (code != 0) {
                LOG.error("afTkjs_appstore 服务端拒绝提供服务");
                return false;
            }
            LOG.error("afTkjs_appstore 调用sidInfo接口结束");
            return true;
        } catch (Exception e) {
            LOG.error("afTkjs_appstore 接口返回异常");
            e.printStackTrace();
            return false;
        }
    }

    private AnfanAccount verifyAccount(String uid, String ucid, String uuid) {
        try {
            LOG.error("afTkjs_appstore 开始调用sidInfo接口:" + serverUrl);

            // 待发送数据
            Map<String, String> params = new HashMap<String, String>();
            params.put("uid", uid);
            params.put("ucid", ucid);
            params.put("uuid", uuid);
            params.put("appId", APP_ID);
            /* 首先以key值自然排序,生成key1=val1&key2=val2......&keyN=valN格式的字符串 */
            List<String> keys = new ArrayList<String>(params.keySet());
            Collections.sort(keys);
            StringBuilder postdatasb = new StringBuilder();
            for (int i = 0; i < keys.size(); i++) {
                String k = keys.get(i);
                String v = params.get(k);
                postdatasb.append(k + "=" + v + "&");
            }
            postdatasb.deleteCharAt(postdatasb.length() - 1);
            String postdata = postdatasb.toString();
            LOG.error("afTkjs_appstore 待签名字符串： " + postdatasb.toString());

            // 对排序后的参数附加开发商签名密钥
            postdatasb.append("&signKey=" + APP_SECRET);
            String sign = MD5Util.toMD5(postdatasb.toString());
            LOG.error("签名值：" + sign);
            postdata += "&sign=" + sign;
            LOG.error("afTkjs_appstore 需要发送到服务器的数据为：" + postdata);

            String result = HttpUtils.sentPost(serverUrl, postdata);

            LOG.error("afTkjs_appstore 收到到服务器的数据为：" + result);

            JSONObject rsp = JSONObject.fromObject(result);
            if (!rsp.containsKey("returnCode")) {
                return null;
            }

            int returnCode = rsp.getInt("returnCode");
            if (returnCode != 0) {
                LOG.error("afTkjs_appstore 服务端拒绝提供服务");
                return null;
            }

            JSONObject data = rsp.getJSONObject("msg");

            AnfanAccount account = new AnfanAccount();
            account.ucid = data.getString("ucid");
            account.uid = data.getString("uid");
            account.uuid = data.getString("uuid");
            account.phone = data.getString("mobile");

            LOG.error("afTkjs_appstore 调用sidInfo接口结束");
            return account;
        } catch (Exception e) {
            LOG.error("afTkjs_appstore 接口返回异常");
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Overriding: doLogin
     *
     * @param param
     * @param response
     * @return
     * @see com.account.plat.PlatInterface#doLogin(JSONObject, JSONObject)
     */
    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return null;
    }

    public boolean verifyPay(String originSign, String openId, String sn) {
        String result = null;
        try {
            LOG.error("verifyPay of afTkjs_appstore");
            JSONObject params = new JSONObject();
            params.put("app_id", APP_ID);
            params.put("open_id", openId);
            params.put("sn", sn);
            @SuppressWarnings("unchecked")
            String signstr = makeSignStr(params);
            LOG.error("afTkjs_appstore signstr " + signstr);
            String sign = MD5Util.toMD5(signstr.toString());
            LOG.error("afTkjs_appstore sign " + sign);
            signstr = signstr.substring(0, signstr.lastIndexOf("&"));
            signstr = signstr + "&sign=" + sign;
            LOG.error("afTkjs_appstore 充值查询接口请求参数" + signstr);
            result = HttpUtils.sentPost(PAY_VERIRY_URL, signstr);
            JSONObject resultObject = JSONObject.fromObject(result);
            if (resultObject.getInt("code") == 0) {
                return true;
            } else {
                LOG.error("接口返回错误 code: " + resultObject.getInt("code") + ", " + resultObject.get("msg"));
                return false;
            }
        } catch (Exception e) {
            LOG.error("接口返回异常:" + result);
            e.printStackTrace();
            return false;
        }
    }

    private String makeSignStr(Map<String, String> map) {
        // 排序key值
        List<String> keys = new ArrayList<String>(map.keySet());
        Collections.sort(keys);
        String signstr = "";
        for (int i = 0; i < keys.size(); i++) {
            String k = keys.get(i);
            String v = map.get(k);
            if (!"sign".equals(k)) {
                signstr = signstr + k + "=" + v + "&";
            }
        }
        signstr = signstr + "sign_key=" + SIGN_KEY;
        return signstr;
    }


    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay of afTkjs_appstore");
        try {
            Map<String, String> params = new HashMap<String, String>();
            for (String key : PAY_BACK_PARAMS) {
                params.put(key, URLDecoder.decode(request.getParameter(key), "UTF-8"));
            }
            String signstr = makeSignStr(params);
            LOG.error("signstr " + signstr);
            String sign = MD5Util.toMD5(signstr);
            LOG.error("sign " + sign);

            if (!APP_ID.equals(params.get("vid"))) {
                LOG.error("afTkjs_appstore 充值应用ID不一致！！ ");
                return "ERROR";
            }

            String originSign = request.getParameter("sign");
            if (sign.equals(originSign)) {
                if (verifyPay(originSign, params.get("open_id"), params.get("sn"))) {
                    PayInfo payInfo = new PayInfo();
                    payInfo.platNo = getPlatNo();

                    payInfo.platId = params.get("open_id");
                    payInfo.serialId = params.get("vorder_id");

                    payInfo.orderId = params.get("sn");
                    // serverId_roleId_timeStamp
                    String[] v = payInfo.serialId.split("_");
                    payInfo.serverId = Integer.valueOf(v[0]);
                    payInfo.roleId = Long.valueOf(v[1]);
                    payInfo.realAmount = Double.valueOf(params.get("fee"));
                    payInfo.amount = (int) (payInfo.realAmount / 1);
                    int code = payToGameServer(payInfo);
                    if (code != 0) {
                        LOG.error("afTkjs_appstore 充值发货失败！！ " + code);
                    }
                    return "SUCCESS";
                } else {
                    LOG.error(" 充值验证失败！！ ");
                    return "ERROR";
                }
            } else {
                LOG.error("afTkjs_appstore 签名不一致！！ " + originSign + "|" + sign);
                return "ERROR";
            }

        } catch (Exception e) {
            LOG.error("afTkjs_appstore 充值异常！！ " + e.getMessage());
            e.printStackTrace();
            return "ERROR";
        }
    }


}
