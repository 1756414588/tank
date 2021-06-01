package com.account.plat.impl.afSq;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
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
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class AfSqPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";
    private static String PAY_URL = "";

    private static String APP_KEY;

    private static String APP_ID;

    private static String method = "GET";

    private static String PAY_APP_ID;
    private static String PAY_APP_KEY;

    private static String SIGN_KEY;

    private static String GAME_ID;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/afSq/", "plat.properties");
        // if (properties != null) {
        APP_ID = properties.getProperty("APP_ID");
        APP_KEY = properties.getProperty("APP_KEY");
        serverUrl = properties.getProperty("VERIRY_URL");
        PAY_URL = properties.getProperty("PAY_URL");
        PAY_APP_ID = properties.getProperty("PAY_APP_ID");
        PAY_APP_KEY = properties.getProperty("PAY_APP_KEY");
        SIGN_KEY = properties.getProperty("SIGN_KEY");
        GAME_ID = properties.getProperty("GAME_ID");
        // CH_APP_KEY = properties.getProperty("CH_APP_KEY");
        // CHECK_URL = properties.getProperty("CHECK_URL");
        // COST_URL = properties.getProperty("COST_URL");
        // }
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

        String openid = vParam[0];
        String openkey = vParam[1];
        String userip = vParam[2];

        if (!verifyAccount(openid, openkey, userip)) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), openid);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(openid);
            account.setAccount(getPlatNo() + "_" + openid);
            account.setPasswd(openid);
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

    // public static String getSign(String method, String uri, HashMap<String,
    // String> params) {
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
    // return MD5.md5Digest(str);
    // }

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

    public String payAfBack(WebRequest request, String content, HttpServletResponse response) {
        // TODO Auto-generated method stub
        LOG.error("pay anfan sq");
        LOG.error("[接收到的参数]" + content);
        try {
            Map<String, String> params = new HashMap<String, String>();
            String[] kvs = content.split("&");
            for (String kv : kvs) {
                String[] k2v = kv.split("=");
                params.put(k2v[0], URLDecoder.decode(k2v[1], "UTF-8"));
            }

            // 排序key值
            List<String> keys = new ArrayList<String>(params.keySet());
            Collections.sort(keys);
            String signstr = "";
            for (int i = 0; i < keys.size(); i++) {
                String k = keys.get(i);
                String v = params.get(k);
                if (!k.equalsIgnoreCase("sign") && !k.equalsIgnoreCase("plat") && !k.equalsIgnoreCase("openId")) {
                    signstr = signstr + k + "=" + v + "&";
                }
            }

            signstr = signstr + "signKey=" + SIGN_KEY;
            LOG.error("signstr " + signstr);
            String sign = md5(signstr.getBytes());
            LOG.error("sign " + sign);

            if (!GAME_ID.equals(params.get("vid"))) {
                LOG.error("anfan sq 充值应用ID不一致！！ ");
                return "ERROR";
            }

            String originSign = params.get("sign");
            if (sign.equalsIgnoreCase(originSign)) {

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                // payInfo.platId = params.get("ucid");
                payInfo.platId = params.get("openId");
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
                    LOG.error("anfan sq 充值发货失败！！ " + code);
                }
                return "SUCCESS";
            } else {
                LOG.error("anfan sq 签名不一致！！ " + originSign + "|" + sign);
                return "ERROR";
            }
        } catch (Exception e) {
            LOG.error("anfan sq 充值异常！！ " + e.getMessage());
            e.printStackTrace();
            return "ERROR";
        }
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay anfan shouq");
        LOG.error("[接收到的参数]" + content);
        try {
            String ucid = request.getParameter("ucid");
            if (ucid != null) {
                return payAfBack(request, content, response);
            }

            Map<String, String[]> paramterMap = request.getParameterMap();
            HashMap<String, String> params = new HashMap<String, String>();
            String k, va;
            Iterator<String> iterator = paramterMap.keySet().iterator();
            while (iterator.hasNext()) {
                k = iterator.next();
                String arr[] = paramterMap.get(k);
                va = (String) arr[0];
                params.put(k, va);
                LOG.error(k + "=" + va);
            }

            LOG.error("[参数结束]");

            JSONObject data = JSONObject.fromObject(params.get("data"));
            String openid = data.getString("openid");
            String openkey = data.getString("openkey");
            String pay_token = data.getString("pay_token");
            String pf = data.getString("pf");
            String pfkey = data.getString("pfkey");
            String serialId = data.getString("serialId");
            String amount = data.getString("amount");
            String sign = data.getString("sign");

            String signSource = openid + openkey + pay_token + pf + pfkey + serialId + amount;
            String orginSign = MD5.md5Digest(signSource);
            LOG.error("签名：" + orginSign + " | " + sign);

            if (orginSign.equals(sign)) {
                // Account account = accountDao.selectByPlatId(getPlatNo(),
                // openid);
                int cost = Integer.valueOf(amount);
                int ret = checkAccount(openid, openkey, pay_token, pf, pfkey, cost * 10);
                if (ret != 0) {
                    if (ret == 1) {
                        LOG.error("af shouq 余额不足！！");
                        return "1";
                    } else {
                        LOG.error("af shouq 余额异常！！");
                        return "2";
                    }
                }

                if (!costMoney(openid, openkey, pay_token, pf, pfkey, serialId, cost * 10)) {
                    LOG.error("af shouq 扣费失败！！");
                    return "3";
                }

                String[] v = serialId.split("_");

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.platId = openid;
                payInfo.orderId = serialId;
                payInfo.serialId = serialId;
                payInfo.serverId = Integer.valueOf(v[0]);
                payInfo.roleId = Long.valueOf(v[1]);
                payInfo.realAmount = Double.valueOf(amount);
                payInfo.amount = cost;
                int code = payToGameServer(payInfo);
                if (code != 0) {
                    LOG.error("af shouq 充值发货失败！！ " + code);
                    return "4";
                }

                return "0";
            } else {
                return "5";
            }
        } catch (Exception e) {
            LOG.error("af1 shouq 余额异常！！" + e.getMessage());
            e.printStackTrace();
            return "6";
        }
    }

    private boolean verifyAccount(String openid, String access_token, String userip) {
        LOG.error("ch shouq开始调用sidInfo接口");
        long timestamp = System.currentTimeMillis() / 1000L;
        String sig = MD5.md5Digest(APP_KEY + timestamp).toLowerCase();
        String url = serverUrl + "/auth/qq_check_token";

        Map<String, String> parameter = new HashMap<String, String>();
        parameter.put("appid", APP_ID);
        parameter.put("openid", openid);
        parameter.put("openkey", access_token);
        parameter.put("userip", userip);
        parameter.put("sig", sig);
        parameter.put("timestamp", String.valueOf(timestamp));
        LOG.error("[请求参数]" + parameter.toString());

        String result = HttpUtils.sendGet(url, parameter);
        // post方式调用服务器接口,请求的body内容是参数json格式字符串
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串
        if (result == null) {
            return false;
        }
        try {
            JSONObject rsp = JSONObject.fromObject(result);
            int ret = rsp.getInt("ret");
            String msg = rsp.getString("msg");
            LOG.error("[ret][msg]" + ret + " " + msg);
            LOG.error("调用sidInfo接口结束");
            if (ret == 0) {
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常 " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public static String getSignNation(Map<String, String> params) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;

        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("sig")) {
                continue;
            }

            if (params.get(k) == null) {
                continue;
            }
            v = (String) params.get(k);

            try {
                // k = UriUtils.encodeQuery(k, "utf-8");
                // v = UriUtils.encodeQuery(v, "utf-8");
                k = URLEncoder.encode(k, "utf-8");
                v = URLEncoder.encode(v, "utf-8");
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            if (str.equals("")) {
                str = k + "=" + v;
            } else {
                str = str + "&" + k + "=" + v;
            }
        }
        return str;
    }

    public String balance(WebRequest request, String content) {
        LOG.error("af shouq balance检查账户余额");

        String openid = request.getParameter("openid");
        String pay_token = request.getParameter("pay_token");
        String pf = request.getParameter("pf");
        String pfkey = request.getParameter("pfkey");

        // UNIX时间戳（从格林威治时间1970年01月01日00时00分00秒起至现在的总秒数）
        try {
            long timestamp = (System.currentTimeMillis() / 1000);

            // cookie值
            Map<String, String> head = new HashMap<String, String>();
            head.put("Cookie", "session_id=openid;session_type=kp_actoken;org_loc=" + URLEncoder.encode("/mpay/get_balance_m", "UTF-8"));

            // 请求参数
            HashMap<String, String> params = new HashMap<>();
            params.put("openid", openid);
            params.put("openkey", pay_token);
            params.put("appid", PAY_APP_ID);
            params.put("ts", String.valueOf(timestamp));
            params.put("pf", pf);
            params.put("pfkey", pfkey);
            params.put("zoneid", "1");

            String sig = SnsSigCheck.makeSig("GET", "/v3/r/mpay/get_balance_m", params, PAY_APP_KEY + "&");
            LOG.error(sig);

            String url = PAY_URL + "/mpay/get_balance_m?" + "openid=" + openid + "&openkey=" + pay_token + "&appid=" + PAY_APP_ID + "&ts=" + timestamp + "&sig="
                    + URLEncoder.encode(sig, "UTF-8") + "&pf=" + pf + "&pfkey=" + pfkey + "&zoneid=1";

            LOG.error("url: " + url);

            String result = HttpUtils.sentGet(url, "UTF-8", head);

            // post方式调用服务器接口,请求的body内容是参数json格式字符串
            LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串
            return result;
        } catch (UnsupportedEncodingException e) {
            LOG.error("检查账户余额异常");
            e.printStackTrace();
        }
        return null;
    }

    /**
     * @param openid
     * @param openkey
     * @param userip
     * @return boolean
     * @throws UnsupportedEncodingException Method: checkAccount
     * @throws
     * @Description: 查询余额
     */
    private int checkAccount(String openid, String openkey, String pay_token, String pf, String pfkey, int amount) throws UnsupportedEncodingException {
        LOG.error("ch shouq 检查账户余额");

        // UNIX时间戳（从格林威治时间1970年01月01日00时00分00秒起至现在的总秒数）
        long timestamp = (System.currentTimeMillis() / 1000);

        // cookie值
        Map<String, String> head = new HashMap<String, String>();
        head.put("Cookie", "session_id=openid;session_type=kp_actoken;org_loc=" + URLEncoder.encode("/mpay/get_balance_m", "UTF-8"));

        // 请求参数
        HashMap<String, String> params = new HashMap<>();
        params.put("openid", openid);
        params.put("openkey", pay_token);
        params.put("appid", PAY_APP_ID);
        params.put("ts", String.valueOf(timestamp));
        params.put("pf", pf);
        params.put("pfkey", pfkey);
        params.put("zoneid", "1");

        String sig = SnsSigCheck.makeSig("GET", "/v3/r/mpay/get_balance_m", params, PAY_APP_KEY + "&");
        LOG.error(sig);

        String url = PAY_URL + "/mpay/get_balance_m?" + "openid=" + openid + "&openkey=" + pay_token + "&appid=" + PAY_APP_ID + "&ts=" + timestamp + "&sig="
                + URLEncoder.encode(sig, "UTF-8") + "&pf=" + pf + "&pfkey=" + pfkey + "&zoneid=1";

        LOG.error("url: " + url);

        String result = HttpUtils.sentGet(url, "UTF-8", head);

        // post方式调用服务器接口,请求的body内容是参数json格式字符串
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

        try {
            JSONObject rsp = JSONObject.fromObject(result);
            int ret = rsp.getInt("ret");
            if (ret == 0) {
                int balance = rsp.getInt("balance");
                if (balance >= amount) {
                    return 0;
                }
                return 1;
            } else {
                return 2;
            }
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常");
            e.printStackTrace();
            return 3;
        }
    }

    private boolean costMoney(String openid, String openkey, String pay_token, String pf, String pfkey, String serialId, int amount)
            throws UnsupportedEncodingException {
        LOG.error("ch shouq开始调用cost接口");
        // 从格林威治时间1970年01月01日00时00分00秒起至现在的总秒数
        long timestamp = (System.currentTimeMillis() / 1000);

        // cookie
        Map<String, String> head = new HashMap<String, String>();
        head.put("Cookie", "session_id=openid;session_type=kp_actoken;org_loc=" + URLEncoder.encode("/mpay/pay_m", "UTF-8"));

        HashMap<String, String> params = new HashMap<>();
        params.put("openid", openid);
        params.put("openkey", pay_token);
        params.put("appid", PAY_APP_ID);
        params.put("ts", String.valueOf(timestamp));
        params.put("pf", pf);
        params.put("pfkey", pfkey);
        params.put("zoneid", "1");
        params.put("amt", String.valueOf(amount));
        params.put("billno", serialId);

        String sig = SnsSigCheck.makeSig(method, "/v3/r/mpay/pay_m", params, PAY_APP_KEY + "&");
        params.put("sig", sig);

        String url = PAY_URL + "/mpay/pay_m?" + "openid=" + openid + "&openkey=" + pay_token + "&appid=" + PAY_APP_ID + "&ts=" + timestamp + "&sig="
                + URLEncoder.encode(sig, "UTF-8") + "&pf=" + pf + "&pfkey=" + pfkey + "&zoneid=1" + "&amt=" + amount + "&billno=" + serialId;

        LOG.error("url: " + url);

        String result = HttpUtils.sentGet(url, "UTF-8", head);

        // post方式调用服务器接口,请求的body内容是参数json格式字符串
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

        try {
            JSONObject rsp = JSONObject.fromObject(result);
            int ret = rsp.getInt("ret");
            if (ret == 0) {
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常");
            e.printStackTrace();
            return false;
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
}
