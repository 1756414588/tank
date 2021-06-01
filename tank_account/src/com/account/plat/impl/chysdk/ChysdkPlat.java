package com.account.plat.impl.chysdk;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.afSq.SnsSigCheck;
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
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.*;

@Component
public class ChysdkPlat extends PlatBase {

    private static String serverUrl = "";

    private static String ServerKey;

    private static String AppId;

    private static String AppKey;

    private static String method = "GET";

    private static String PAY_URL = "";

    private static String APP_ID_QQ;

    private static String APP_ID_WX;

    private static String PAY_APP_KEY;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chysdk/", "plat.properties");
        ServerKey = properties.getProperty("ServerKey");
        AppId = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
        serverUrl = properties.getProperty("VERIRY_URL");
        PAY_URL = properties.getProperty("PAY_URL");
        APP_ID_QQ = properties.getProperty("APP_ID_QQ");
        APP_ID_WX = properties.getProperty("APP_ID_WX");
        PAY_APP_KEY = properties.getProperty("PAY_APP_KEY");
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String[] vParam = sid.split("_");
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[0];
        if (!verifyAccount(vParam[0], vParam[1])) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userId);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(getPlatNo());
            account.setPlatId(userId);
            account.setAccount(getPlatNo() + "_" + userId);
            account.setPasswd(userId);
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
        response.setUserInfo(userId);

        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }


    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        String extra = request.getParameter("extra");
        String[] v = extra.split("_");
        String result = null;
        if (v[3].equals("3")) {
            result = payCh(request, content, response);
        } else if (v[3].equals("1")) {
            result = payQQ(request, content, response);
        } else if (v[3].equals("2")) {
            result = payWX(request, content, response);
        }
        return result;
    }

    private boolean verifyAccount(String uid, String Token) {
        LOG.error("Chysdk 开始调用sidInfo接口");
        Date now = new Date();
        long time = now.getTime() / 1000;

        String signStr = "appid=" + AppId + "&times=" + time + "&token=" + Token + "&userid=" + uid + AppKey;
        LOG.error("待签名字符串:" + signStr);
        try {
            String sign = MD5.md5Digest(signStr).toUpperCase();
            LOG.error("签名:" + sign);
            String body = "appid=" + AppId + "&times=" + time + "&token=" + Token + "&userid=" + uid + "&sign=" + sign;
            LOG.error("请求参数:" + body);
            String result = HttpUtils.sentPost(serverUrl, body);
            LOG.error("[响应结果]" + result);
            JSONObject rsp = JSONObject.fromObject(result);
            int returnCode = rsp.getInt("code");
            if (returnCode == 200) {
                LOG.error("验证成功");
                return true;
            }
            LOG.error("验证失败 ");
            return false;
        } catch (Exception e) {
            LOG.error("Chysdk 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("Chysdk 调用sidInfo接口结束");
        }
    }

    private String payCh(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay Chysdk_CH");
        JSONObject json = new JSONObject();
        try {
            String orderno = request.getParameter("orderno");
            String orderno_cp = request.getParameter("orderno_cp");
            String userid = request.getParameter("userid");
            String order_amt = request.getParameter("order_amt");
            String pay_amt = request.getParameter("pay_amt");
            String pay_time = request.getParameter("pay_time");
            String extra = request.getParameter("extra");
            String sign = request.getParameter("sign");

            String signStr = "extra=" + extra + "&order_amt=" + order_amt + "&orderno=" + orderno + "&orderno_cp=" + orderno_cp + "&pay_amt=" + pay_amt + "&pay_time=" + pay_time + "&userid=" + userid + ServerKey;
            LOG.error("[签名原文]" + signStr);
            String signCheck = MD5.md5Digest(signStr).toUpperCase();
            LOG.error("[签名结果]" + signCheck);
            if (!sign.equals(signCheck)) {  // 签名失败
                LOG.error("Chysdk sign error");
                json.put("code", 202);
                json.put("msg", "失败");
                return json.toString();
            }

            String[] v = extra.split("_");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = userid;
            payInfo.orderId = orderno;

            payInfo.serialId = extra;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(pay_amt) / 100;
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);

            if (code == 0) {
                LOG.error("Chysdk 充值发货成功 ");
            } else if (code == 1) {
                LOG.error("Chysdk 重复的订单号！！ " + code);
            } else {
                LOG.error("Chysdk 充值发货失败！！ " + code);
                json.put("code", 203);
                json.put("msg", "失败");
                return json.toString();
            }
            json.put("code", 200);
            json.put("msg", "成功");
            return json.toString();
        } catch (Exception e) {
            LOG.error("Chysdk 充值异常:" + e.getMessage());
            e.printStackTrace();
            json.put("code", 203);
            json.put("msg", "失败");
            return json.toString();
        }
    }

    private String payQQ(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay Chysdk_QQ");
        LOG.error("[接收到的参数]" + content);
        try {
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
                int ret = checkAccount(openid, openkey, pay_token, pf, pfkey, cost * 10, APP_ID_QQ, PAY_APP_KEY);
                if (ret != 0) {
                    if (ret == 1) {
                        LOG.error("ch shouq1 余额不足！！");
                        return "1";
                    } else {
                        LOG.error("ch shouq1 余额异常！！");
                        return "2";
                    }
                }

                if (!costMoney(openid, openkey, pay_token, pf, pfkey, serialId, cost * 10, APP_ID_QQ, PAY_APP_KEY)) {
                    LOG.error("ch shouq1 扣费失败！！");
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
                    LOG.error("ch shouq1 充值发货失败！！ " + code);
                    return "4";
                }

                LOG.error("ch shouq1 充值发货成功");
                return "0";
            } else {
                LOG.error("ch shouq1 签名验证失败");
                return "5";
            }
        } catch (Exception e) {
            LOG.error("ch shouq1 充值异常:" + e.getMessage());
            e.printStackTrace();
            return "6";
        }
    }

    private String payWX(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay Chysdk_WX");
        LOG.error("[接收到的参数]" + content);
        try {

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
                int ret = checkAccount(openid, openkey, pay_token, pf, pfkey, cost * 10, APP_ID_WX, PAY_APP_KEY);
                if (ret != 0) {
                    if (ret == 1) {
                        LOG.error("ch weixin1 余额不足！！");
                        return "1";
                    } else {
                        LOG.error("ch weixin1 余额异常！！");
                        return "2";
                    }
                }

                if (!costMoney(openid, openkey, pay_token, pf, pfkey, serialId, cost * 10, APP_ID_WX, PAY_APP_KEY)) {
                    LOG.error("ch weixin1 扣费失败！！");
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
                    LOG.error("ch weixin1 充值发货失败！！ " + code);
                    return "4";
                }

                LOG.error("ch weixin1 充值发货成功 ");
                return "0";
            } else {
                LOG.error("ch weixin1 签名验证失败 ");
                return "5";
            }
        } catch (Exception e) {
            LOG.error("ch weixin1 充值异常:" + e.getMessage());
            e.printStackTrace();
            return "6";
        }
    }

    private int checkAccount(String openid, String openkey, String pay_token, String pf, String pfkey, int amount, String PAY_APP_ID, String PAY_APP_KEY) throws UnsupportedEncodingException {
        LOG.error("ch shouq1 检查账户余额");

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

    private boolean costMoney(String openid, String openkey, String pay_token, String pf, String pfkey, String serialId, int amount, String PAY_APP_ID, String PAY_APP_KEY)
            throws UnsupportedEncodingException {
        LOG.error("ch shouq1开始调用cost接口");
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

    public String balance(WebRequest request, String content) {
        LOG.error("ch shouq1 balance检查账户余额");

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
            params.put("appid", APP_ID_QQ);
            params.put("ts", String.valueOf(timestamp));
            params.put("pf", pf);
            params.put("pfkey", pfkey);
            params.put("zoneid", "1");

            String sig = SnsSigCheck.makeSig("GET", "/v3/r/mpay/get_balance_m", params, PAY_APP_KEY + "&");
            LOG.error(sig);

            String url = PAY_URL + "/mpay/get_balance_m?" + "openid=" + openid + "&openkey=" + pay_token + "&appid=" + APP_ID_QQ + "&ts=" + timestamp + "&sig="
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

    /*public static void main(String[] args) {
        String sign;
        sign = MD5.md5Digest("appid=1006&times=1501484141&token=gkeVZbOv31JnkERQ2xUDteJGWz64lZro7pvHqkS7RIfHLz/GzYtgeXYooKWInA18AYm66mouWGOHGMmBefOUlHEiFCjr/T06iDCC1Hjv719ZK0B8UBECjHCTfEF/rs9KXhqdSka8v40uBWguNgiF/NK2ZRnTf2zzINCcON1lr14=&userid=100000379FEF5539F9F6BAF0CD11C666FA0B6978").toUpperCase();
        LOG.error("签名:" + sign);
        String body = "appid=" + 1006 + "&times=" + 1501484141 + "&token=" + "gkeVZbOv31JnkERQ2xUDteJGWz64lZro7pvHqkS7RIfHLz/GzYtgeXYooKWInA18AYm66mouWGOHGMmBefOUlHEiFCjr/T06iDCC1Hjv719ZK0B8UBECjHCTfEF/rs9KXhqdSka8v40uBWguNgiF/NK2ZRnTf2zzINCcON1lr14=" + "&userid=" + 10000037 + "&sign=" + sign;
        LOG.error("请求参数:" + body);
        String result = HttpUtils.sentPost("http://passport.ysdk.yx27.com/api/verifyToken", body);
        LOG.error("[响应结果]" + result);

        try {
            long time = System.currentTimeMillis() / 1000;
            StringBuffer sb = new StringBuffer();
            sb.append("appid=");
            sb.append(1006);
            sb.append("&times=");
            sb.append(1501484141);
            sb.append("&token=");
            sb.append("gkeVZbOv31JnkERQ2xUDteJGWz64lZro7pvHqkS7RIfHLz/GzYtgeXYooKWInA18AYm66mouWGOHGMmBefOUlHEiFCjr/T06iDCC1Hjv719ZK0B8UBECjHCTfEF/rs9KXhqdSka8v40uBWguNgiF/NK2ZRnTf2zzINCcON1lr14=");
            sb.append("&userid=");
            sb.append(10000037);
            String signSource = sb.toString() + "9FEF5539F9F6BAF0CD11C666FA0B6978";
            String sign2 = MD5.md5Digest(signSource).toUpperCase();
            sb.append("&sign=");
            sb.append(sign2);
            LOG.error("需要发送到服务器的数据为：" + sb.toString());
            String result2 = HttpUtils.sentPost("http://passport.ysdk.yx27.com/api/verifyToken", sb.toString());
            LOG.error("[响应结果]" + result2);
        } catch (Exception e) {
            // TODO: handle exception
        }
    }*/
}
