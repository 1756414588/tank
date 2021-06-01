package com.account.plat.impl.afXzlmAppstore;

import java.net.URLDecoder;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
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
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

class AnfanAccount {
    public String ucid;// id
    public String uid; // name
    public String phone;
    public String uuid; // 授权码
}

@Component
public class AfXzlmAppstorePlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    private static String SIGN_KEY;
    private static String APP_SECRET;
    private static String APP_ID;
    private static String PAY_VERIRY_URL;
    private static String PAY_VERIRY_URL_SANBOX;

    private static Map<Integer, String> RECHARGE_MAP = new HashMap<Integer, String>();
    private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/afXzlmAppstore/", "plat.properties");
        SIGN_KEY = properties.getProperty("SIGN_KEY");
        APP_SECRET = properties.getProperty("APP_SECRET");
        serverUrl = properties.getProperty("VERIRY_URL");
        APP_ID = properties.getProperty("APP_ID");
        PAY_VERIRY_URL = properties.getProperty("PAY_VERIRY_URL");
        PAY_VERIRY_URL_SANBOX = properties.getProperty("PAY_VERIRY_URL_SANBOX");
        initRechargeMap();
    }

    private void initRechargeMap() {
        RECHARGE_MAP.put(1, "com.tank.xzlm60");
        MONEY_MAP.put(1, 6);

        RECHARGE_MAP.put(2, "com.tank.xzlm300");
        MONEY_MAP.put(2, 30);

        RECHARGE_MAP.put(3, "com.tank.xzlm980");
        MONEY_MAP.put(3, 98);

        RECHARGE_MAP.put(4, "com.tank.xzlm1980");
        MONEY_MAP.put(4, 198);

        RECHARGE_MAP.put(5, "com.tank.xzlm3280");
        MONEY_MAP.put(5, 328);

        RECHARGE_MAP.put(6, "com.tank.xzlm6480");
        MONEY_MAP.put(6, 648);
    }

    public static String md5(byte[] source) {
        String s = null;
        char hexDigits[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};// 用来将字节转换成16进制表示的字符
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
            md.update(source);
            byte tmp[] = md.digest();// MD5 的计算结果是一个 128 位的长整数，
            // 用字节表示就是 16 个字节
            char str[] = new char[16 * 2];// 每个字节用 16 进制表示的话，使用两个字符， 所以表示成 16
            // 进制需要 32 个字符
            int k = 0;// 表示转换结果中对应的字符位置
            for (int i = 0; i < 16; i++) {// 从第一个字节开始，对 MD5 的每一个字节// 转换成 16
                // 进制字符的转换
                byte byte0 = tmp[i];// 取第 i 个字节
                str[k++] = hexDigits[byte0 >>> 4 & 0xf];// 取字节中高 4 位的数字转换,// >>>
                // 为逻辑右移，将符号位一起右移
                str[k++] = hexDigits[byte0 & 0xf];// 取字节中低 4 位的数字转换

            }
            s = new String(str);// 换后的结果转换为字符串

        } catch (NoSuchAlgorithmException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return s;
    }

    public int getPlatNo() {  // // 角色与安锋老天启狂怒互通
        return 95;
    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String[] vParam = sid.split("&");
        if (vParam.length < 3) {
            return GameError.PARAM_ERROR;
        }

        String uid = vParam[0];
        String ucid = vParam[1];
        String uuid = vParam[2];

        AnfanAccount anfanAccount = verifyAccount(uid, ucid, uuid);
        if (anfanAccount == null) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), anfanAccount.ucid);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(getPlatNo());
            account.setChildNo(super.getPlatNo());
            account.setPlatId(anfanAccount.ucid);
            account.setAccount(getPlatNo() + "_" + anfanAccount.ucid);
            account.setPasswd(anfanAccount.uid);
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

    // @Override
    // public GameError doLogin(JSONObject param, JSONObject response) {
    // // TODO Auto-generated method stub
    // if (!param.containsKey("sid") || !param.containsKey("baseVersion") ||
    // !param.containsKey("version") || !param.containsKey("deviceNo")) {
    // return GameError.PARAM_ERROR;
    // }
    //
    // String sid = param.getString("sid");
    // String baseVersion = param.getString("baseVersion");
    // String versionNo = param.getString("version");
    // String deviceNo = param.getString("deviceNo");
    //
    // AnfanAccount qihuAccount = verifyAccount(sid);
    // if (qihuAccount == null) {
    // return GameError.SDK_LOGIN;
    // }
    //
    // Account account = accountDao.selectByPlatId(getPlatNo(), qihuAccount.id);
    // if (account == null) {
    // String token = RandomHelper.generateToken();
    // account = new Account();
    // account.setPlatNo(this.getPlatNo());
    // account.setPlatId(qihuAccount.id);
    // account.setAccount(getPlatNo() + "_" + qihuAccount.id);
    // account.setPasswd(qihuAccount.id);
    // account.setBaseVersion(baseVersion);
    // account.setVersionNo(versionNo);
    // account.setToken(token);
    // account.setDeviceNo(deviceNo);
    // Date now = new Date();
    // account.setLoginDate(now);
    // account.setCreateDate(now);
    // accountDao.insertWithAccount(account);
    // } else {
    // String token = RandomHelper.generateToken();
    // account.setToken(token);
    // account.setVersionNo(versionNo);
    // account.setDeviceNo(deviceNo);
    // account.setLoginDate(new Date());
    // accountDao.updateTokenAndVersion(account);
    // }
    //
    // GameError authorityRs = super.checkAuthority(account);
    // if (authorityRs != GameError.OK) {
    // return authorityRs;
    // }
    //
    // response.put("recent", super.getRecentServers(account));
    // response.put("keyId", account.getKeyId());
    // response.put("token", account.getToken());
    // response.put("userInfo", qihuAccount.userInfo);
    // if (isActive(account)) {
    // response.put("active", 1);
    // } else {
    // response.put("active", 0);
    // }
    //
    // return GameError.OK;
    // }

    // public static String getSign(HashMap<String, String> params, String
    // appSecret) {
    // Object[] keys = params.keySet().toArray();
    // Arrays.sort(keys);
    // String k, v;
    //
    // String str = "";
    // for (int i = 0; i < keys.length; i++) {
    // k = (String) keys[i];
    // if (k.equals("sign") || k.equals("plat") || k.equals("sign_return")) {
    // continue;
    // }
    //
    // if (params.get(k) == null) {
    // continue;
    // }
    // v = (String) params.get(k);
    //
    // if (v.equals("0") || v.equals("")) {
    // continue;
    // }
    // str += v + "#";
    // }
    // LOG.error("getSign:" + str);
    // return MD5.md5Digest(str + appSecret);
    // }

    // @Override
    // public String payBack(WebRequest request, String content,
    // HttpServletResponse response) {
    // LOG.error("pay qihu");
    // // LOG.error("[接收到的参数]" + content);
    // try {
    // Map<String, String[]> paramterMap = request.getParameterMap();
    // HashMap<String, String> params = new HashMap<String, String>();
    // String k, v;
    // Iterator<String> iterator = paramterMap.keySet().iterator();
    // while (iterator.hasNext()) {
    // k = iterator.next();
    // String arr[] = paramterMap.get(k);
    // v = (String) arr[0];
    // params.put(k, v);
    // LOG.error(k + "=" + v);
    // }
    // LOG.error("[参数结束]");
    // String app_key = request.getParameter("app_key");
    // // String product_id = request.getParameter("product_id");
    // String amount = request.getParameter("amount");
    // // String app_uid = request.getParameter("app_uid");
    // String app_ext1 = request.getParameter("app_ext1");
    // // String app_ext2 = request.getParameter("app_ext2");
    // // String user_id = request.getParameter("user_id");
    // String order_id = request.getParameter("order_id");
    // String gateway_flag = request.getParameter("gateway_flag");
    // // String sign_type = request.getParameter("sign_type");
    // // String app_order_id = request.getParameter("app_order_id");
    // // String sign_return = request.getParameter("sign_return");
    // String sign = request.getParameter("sign");
    //
    // if (!APP_KEY.equals(app_key)) {
    // return "ok";
    // }
    //
    // if (!"success".equals(gateway_flag)) {
    // return "ok";
    // }
    //
    // String orginSign = getSign(params, APP_SECRET);
    // LOG.error("签名：" + orginSign + " | " + sign);
    //
    // if (orginSign.equals(sign)) {
    // String[] infos = app_ext1.split(",");
    // if (infos.length != 4) {
    // return "ok";
    // }
    // Long lordId = Long.valueOf(infos[0]);
    // int serverid = Integer.valueOf(infos[1]);
    // int rechargeId = Integer.valueOf(infos[2]);
    // String exorderno = infos[3];
    //
    // int rsCode = payResult(lordId, serverid, Double.valueOf(amount),
    // rechargeId, order_id, exorderno);
    // if (rsCode == 200) {
    // LOG.error("返回充值成功");
    // return "ok";
    // } else {
    // LOG.error("返回充值失败");
    // return "ok";
    // }
    // } else {
    // return "ok";
    // }
    // } catch (Exception e) {
    // e.printStackTrace();
    // return "ok";
    // }
    // }

    private AnfanAccount verifyAccount(String uid, String ucid, String uuid) {
        try {
            LOG.error("anfan开始调用sidInfo接口:" + serverUrl);

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
            LOG.error("待签名字符串： " + postdatasb.toString());

            // 对排序后的参数附加开发商签名密钥
            postdatasb.append("&signKey=" + APP_SECRET);
            String sign = md5(postdatasb.toString().getBytes());
            LOG.error("签名值：" + sign);
            postdata += "&sign=" + sign;
            LOG.error("需要发送到服务器的数据为：" + postdata);

            String result = HttpUtils.sentPost(serverUrl, postdata);

            LOG.error("收到到服务器的数据为：" + result);

            JSONObject rsp = JSONObject.fromObject(result);
            if (!rsp.containsKey("returnCode")) {
                return null;
            }

            int returnCode = rsp.getInt("returnCode");
            if (returnCode != 0) {
                LOG.error("服务端拒绝提供服务");
                return null;
            }

            JSONObject data = rsp.getJSONObject("msg");

            AnfanAccount account = new AnfanAccount();
            account.ucid = data.getString("ucid");
            account.uid = data.getString("uid");
            account.uuid = data.getString("uuid");
            account.phone = data.getString("mobile");

            LOG.error("调用sidInfo接口结束");
            return account;
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常 " + e.getMessage());
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
     * @see com.account.plat.PlatInterface#doLogin(net.sf.json.JSONObject,
     * net.sf.json.JSONObject)
     */
    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        // TODO Auto-generated method stub
        LOG.error("pay afXzlm_appstore");
        LOG.error("[接收到的参数]" + content);
        try {
            Map<String, String> params = new HashMap<String, String>();
            String[] kvs = content.split("&");
            for (String kv : kvs) {
                String[] k2v = kv.split("=");
                params.put(k2v[0], URLDecoder.decode(k2v[1], "UTF-8"));
            }

            // for (Iterator<String> it = params.keySet().iterator();
            // it.hasNext();) {
            // String k = (String) it.next();
            // String v = (String) params.get(k);
            // }

            // 排序key值
            List<String> keys = new ArrayList<String>(params.keySet());
            Collections.sort(keys);
            String signstr = "";
            for (int i = 0; i < keys.size(); i++) {
                String k = keys.get(i);
                String v = params.get(k);
                if (!k.equalsIgnoreCase("sign") && !k.equalsIgnoreCase("plat")) {
                    signstr = signstr + k + "=" + v + "&";
                }
            }

            signstr = signstr + "signKey=" + SIGN_KEY;
            LOG.error("signstr " + signstr);
            String sign = md5(signstr.getBytes());
            LOG.error("sign " + sign);

            if (!APP_ID.equals(params.get("vid"))) {
                LOG.error("afXzlm_appstore 充值应用ID不一致！！ ");
                return "ERROR";
            }

            String originSign = params.get("sign");
            if (sign.equalsIgnoreCase(originSign)) {

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.childNo = super.getPlatNo();
                payInfo.platId = params.get("ucid");
                payInfo.orderId = params.get("sn");
                payInfo.serialId = params.get("vorderid");

                // serverId_roleId_timeStamp
                String[] v = payInfo.serialId.split("_");
                payInfo.serverId = Integer.valueOf(v[0]);
                payInfo.roleId = Long.valueOf(v[1]);
                payInfo.realAmount = Double.valueOf(params.get("fee"));
                payInfo.amount = (int) (payInfo.realAmount / 1);
                int code = payToGameServer(payInfo);
                if (code != 0) {
                    LOG.error("afXzlm_appstore 充值发货失败！！ " + code);
                }
                return "SUCCESS";
            } else {
                LOG.error("afXzlm_appstore 签名不一致！！ " + originSign + "|" + sign);
                return "ERROR";
            }
        } catch (Exception e) {
            LOG.error("afXzlm_appstore 充值异常！！ " + e.getMessage());
            e.printStackTrace();
            return "ERROR";
        }
    }

}
