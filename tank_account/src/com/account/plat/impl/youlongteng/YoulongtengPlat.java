package com.account.plat.impl.youlongteng;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
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
public class YoulongtengPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    private static String PAY_URL = "";

    // 游戏编号
    private static String AppID;

    // 分配给游戏合作商的接入密钥,请做好安全保密
    private static String SecretKey = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/youlongteng/", "plat.properties");
        AppID = properties.getProperty("AppID");
        SecretKey = properties.getProperty("SecretKey");
        serverUrl = properties.getProperty("VERIRY_URL");
        PAY_URL = properties.getProperty("PAY_URL");
    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        // TODO Auto-generated method stub
        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String uid = verifyAccount(deviceNo, sid);
        if (uid == null) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), uid);

        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(uid);
            account.setAccount(getPlatNo() + "_" + uid);
            account.setPasswd(uid);
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

    private String packResponse(int ResultCode, String msg) {
        JSONObject res = new JSONObject();
        res.put("code", ResultCode);
        res.put("message", msg);
        return res.toString();
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay youlongteng");
        LOG.error("[接收到的参数]" + content);

        Map<String, String> parameter = new HashMap<String, String>();
        Iterator<String> it = request.getParameterNames();
        while (it.hasNext()) {
            String paramName = it.next();
            String paramValue = request.getParameter(paramName);
            parameter.put(paramName, paramValue);
            LOG.error(paramName + ":" + paramValue);
        }

        try {
            String order_sn = request.getParameter("order_sn");
            String uid = request.getParameter("uid");
            String status = request.getParameter("status");
            String amount = request.getParameter("amount");
            // String currency = request.getParameter("currency");
            // String targetamonut = request.getParameter("targetamonut");
            // String product_id = request.getParameter("product_id");
            // String platment = request.getParameter("platment");
            // String game_area = request.getParameter("game_area");
            // String apply_time = request.getParameter("apply_time");
            String exts = request.getParameter("exts");
            String oauth_signature = request.getParameter("oauth_signature");// 签名

            if (status == null || !status.equals("1")) {
                return packResponse(1, "status not 1");
            }

            String s1 = URLEncoder.encode(getSignNation(parameter), "utf-8");
            LOG.error("[S1]" + s1);
            String s2 = URLEncoder.encode(PAY_URL, "utf-8");
            LOG.error("[S2]" + s2);
            String s3 = "POST&" + s2 + "&" + s1;
            LOG.error("[S3]" + s3);
            String s4 = SecretKey + "&";
            LOG.error("[S4]" + s4);
            String sign = MD5.md5Digest(s4 + s3);

            LOG.error("[签名原文]" + s4 + s3);
            LOG.error("[签名结果]" + oauth_signature + "|" + sign);

            if (oauth_signature == null || !oauth_signature.equals(sign)) {
                LOG.error("签名不正确");
                return packResponse(1, "sign error");
            }

            String[] infos = exts.split("_");
            if (infos.length != 3) {
                LOG.error("自有参数不正确");
                return packResponse(1, "cp exts parameter error");
            }
            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = uid;
            payInfo.orderId = order_sn;

            payInfo.serialId = exts;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(amount.trim());
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);

            if (code != 0) {
                LOG.error("youlongteng 充值发货失败！！ " + code);
                return packResponse(1, "send gold fail").toString();
            } else {
                LOG.error("youlongteng 充值发货成功！！ " + code);
                return packResponse(0, "success").toString();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return packResponse(1, "sys exception").toString();
        }
    }

    public static String getSignNation(Map<String, String> params) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;

        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("oauth_signature")) {
                continue;
            }
            if (k.equals("plat")) {
                continue;
            }

            if (params.get(k) == null) {
                continue;
            }
            v = (String) params.get(k);

            // try {
            k = encode(k);
            v = encode(v);
            // } catch (UnsupportedEncodingException e) {
            // e.printStackTrace();
            // }

            if (str.equals("")) {
                str = k + "=" + v;
            } else {
                str = str + "&" + k + "=" + v;
            }
        }
        return str;
    }

    private String verifyAccount(String udid, String token) {
        LOG.error("youlongteng 开始调用sidInfo接口");

        String oauth_signature = "";
        String oauth_timestamp = String.valueOf(System.currentTimeMillis());
        Map<String, String> parameter = new HashMap<String, String>();
        parameter.put("token", token);
        parameter.put("udid", udid);
        parameter.put("oauth_consumer_key", AppID);
        parameter.put("oauth_signature_method", "md5");
        parameter.put("oauth_nonce", oauth_timestamp + token);
        parameter.put("oauth_timestamp", oauth_timestamp);
        parameter.put("oauth_version", String.valueOf(1.0));

        try {
            String s1 = URLEncoder.encode(getSignNation(parameter), "utf-8");
            LOG.error("[S1]" + s1);
            String s2 = URLEncoder.encode(serverUrl, "utf-8");
            LOG.error("[S2]" + s2);
            String s3 = "GET&" + s2 + "&" + s1;
            LOG.error("[S3]" + s3);
            String s4 = SecretKey + "&";
            LOG.error("[S4]" + s4);
            oauth_signature = MD5.md5Digest(s4 + s3);
            parameter.put("oauth_signature", oauth_signature);
        } catch (UnsupportedEncodingException e1) {
            e1.printStackTrace();
        }

        LOG.error("[请求URL]" + serverUrl);
        LOG.error("[请求参数]" + parameter.toString());

        String result = HttpUtils.sendGet(serverUrl, parameter);

        // post方式调用服务器接口,请求的body内容是参数json格式字符串
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串
        if (result == null) {
            return null;
        }
        try {
            JSONObject rsp = JSONObject.fromObject(result);
            int code = rsp.getInt("code");
            if (code == 0) {
                JSONObject data = rsp.getJSONObject("data");
                return data.getString("ppuserid");
            }
            return null;
        } catch (Exception e) {
            LOG.error("接口返回异常");
            e.printStackTrace();
            return null;
        }
    }

    public static String encode(String param) {
        try {
            return URLEncoder.encode(param, "utf-8").replace("+", "%20").replace("*", "%2A").replace("%7E", "~");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }

    public static void main(String[] args) {
        // String oauth_signature = "4f6f6ffc58de6cb634a56526d4de3b09";
        // String SecretKey = "J2k0nTEMSV2XhkYzDxE3l5Wb0tyVAEHm8g0pLxCb";
        // String PAY_URL =
        // "http://ylt.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=ylt";
        // Map<String, String> param = new HashMap<String, String>();
        // param.put("uid", "1500013225");
        // param.put("apply_time", "2016-06-12 09:51:28");
        // param.put("product_id", "1");
        // param.put("oauth_version", "1.0");
        // param.put("status", "1");
        // param.put("oauth_nonce", "1465698229");
        // param.put("oauth_consumer_key", "2000");
        // param.put("currency", "rmb");
        // param.put("amount", "10.0000");
        // param.put("plat", "ylt");
        // param.put("targetamount", "100.00");
        // param.put("exts", "1_135290_1465696286982");
        // param.put("oauth_signature", "4f6f6ffc58de6cb634a56526d4de3b09");
        // param.put("oauth_signature_method", "md5");
        // param.put("game_area", "1");
        // param.put("order_sn", "201606120951280000039680");
        // param.put("platment", "googleplay");
        // param.put("oauth_timestamp", "1465698229");
        //
        // String s = getSignNation(param);
        // LOG.error("[s]" + s);
        // String s1 = encode(s);
        // LOG.error("[S1]" + s1);
        // String s2 = encode(PAY_URL);
        // LOG.error("[S2]" + s2);
        // String s3 = "POST&" + s2 + "&" + s1;
        // LOG.error("[S3]" + s3);
        // String s4 = SecretKey + "&";
        // LOG.error("[S4]" + s4);
        // String sign = MD5.md5Digest(s4 + s3);
        //
        // LOG.error("[签名原文]" + s4 + s3);
        // LOG.error("[签名结果]" + oauth_signature + "|" + sign);

		/*String Url = "http://us.p1.youlongteng.com/service/gs/token";
		String SecretKey = "J2k0nTEMSV2XhkYzDxE3l5Wb0tyVAEHm8g0pLxCb";
		String AppID = "2000";
		LOG.error("youlongteng 开始调用sidInfo接口");
		String token = "2657d8f525f528055b2b83ab36fa015940c80aa3c8d53a80245c9f5e76905c0496cd12a47646b28d9PZCT2Q6";
		String oauth_signature = "";
		String oauth_timestamp = String.valueOf(System.currentTimeMillis());
		Map<String, String> parameter = new HashMap<String, String>();
		parameter.put("token", token);
		parameter.put("udid", "ffffffff-bd51-6aef-9e49-28560033c587");
		parameter.put("oauth_consumer_key", AppID);
		parameter.put("oauth_signature_method", "md5");
		parameter.put("oauth_nonce", oauth_timestamp + token);
		parameter.put("oauth_timestamp", oauth_timestamp);
		parameter.put("oauth_version", String.valueOf(1.0));

		try {
			String s1 = URLEncoder.encode(getSignNation(parameter), "utf-8");
			LOG.error("[S1]" + s1);
			String s2 = URLEncoder.encode(Url, "utf-8");
			LOG.error("[S2]" + s2);
			String s3 = "GET&" + s2 + "&" + s1;
			LOG.error("[S3]" + s3);
			String s4 = SecretKey + "&";
			LOG.error("[S4]" + s4);
			oauth_signature = MD5.md5Digest(s4 + s3);
			parameter.put("oauth_signature", oauth_signature);
			LOG.error("[请求URL]" + Url);
			LOG.error("[请求参数]" + parameter.toString());

			String result = HttpUtils.sendGet(Url, parameter);
			LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串
		} catch (UnsupportedEncodingException e1) {
			e1.printStackTrace();
		}*/

        // post方式调用服务器接口,请求的body内容是参数json格式字符串
    }
}
