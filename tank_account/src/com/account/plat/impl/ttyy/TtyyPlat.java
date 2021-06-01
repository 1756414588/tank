package com.account.plat.impl.ttyy;

import java.net.URLDecoder;
import java.util.*;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import com.account.plat.impl.kaopu.MD5Util;
import com.alibaba.fastjson.JSON;
import com.test.Base64;
import io.netty.handler.codec.base64.Base64Encoder;
import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import sun.misc.BASE64Encoder;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class TtyyPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static String APP_ID;

    private static String APP_SECRET = "";

    // private static String PAY_KEY = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/ttyy/", "plat.properties");
        APP_ID = properties.getProperty("APP_ID");
        APP_SECRET = properties.getProperty("APP_SECRET");
        serverUrl = properties.getProperty("VERIRY_URL");
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

        String[] vParam = sid.split(",");
        if (vParam.length < 1) {
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[1];
        String sessionId = vParam[0];

        if (vParam.length == 2) {
            if (!verifyAccount(userId, sessionId)) {
                return GameError.SDK_LOGIN;
            }
        } else {
            if (!newVerifyAccount(userId, sessionId)) {
                return GameError.SDK_LOGIN;
            }
        }


        Account account = accountDao.selectByPlatId(getPlatNo(), userId);

        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
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

        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay ttyy");
        JSONObject rs = new JSONObject();
        JSONObject head = new JSONObject();
        try {
            String sign = request.getHeader("sign");
            LOG.error("payttyy 接收sign" + sign);
            LOG.error("payttyy 接收参数" + content);

            content = URLDecoder.decode(content, "utf-8");

            LOG.error("payttyy 接收参数" + content);


            JSONObject param = JSONObject.fromObject(content);
            String uid = param.getString("uid");
            String gameId = param.getString("gameId");
            String sdkOrderId = param.getString("sdkOrderId");
            String cpOrderId = param.getString("cpOrderId");
            String payFee = param.getString("payFee");
            String payResult = param.getString("payResult");
            String payDate = param.getString("payDate");
            String exInfo = param.getString("exInfo");

            String signNation = content + APP_SECRET;
            BASE64Encoder baseEncoder = new BASE64Encoder();
            String tosign = baseEncoder.encode(MD5.md5SrcDigest(signNation));
            LOG.error("[签名原文]" + signNation);
            LOG.error("[签名结果]" + sign + "|" + tosign);

            if (!sign.equals(tosign)) {
                String newSignNation = content + "6b8e8f830dfa2b3133e2fb9c15ae5fd2";
                BASE64Encoder baseEncoder2 = new BASE64Encoder();
                String newTosign = baseEncoder2.encode(MD5.md5SrcDigest(newSignNation));
                if (!sign.equals(newTosign)) {
                    LOG.error("签名失败");
                    head.put("result", 1);
                    head.put("message", "sign error");
                    rs.put("head", head);
                    return rs.toString();
                }
            }

            if (!"1".equals(payResult)) {
                LOG.error("扣费不成功");
                head.put("result", 2);
                head.put("message", "pay fail");
                rs.put("head", head);
                return rs.toString();
            }
            String[] infos = exInfo.split("_");
            if (infos.length != 3) {
                LOG.error("传参不正确");
                head.put("result", 3);
                head.put("message", "cp param error");
                rs.put("head", head);
                return rs.toString();
            }
            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = uid;
            payInfo.orderId = sdkOrderId;

            payInfo.serialId = exInfo;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(payFee);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int retcode = payToGameServer(payInfo);
            if (retcode == 0) {
                LOG.error("返回充值成功");
                head.put("result", 0);
                head.put("message", "");
                rs.put("head", head);
                return rs.toString();
            } else {
                LOG.error("返回充值失败");
                head.put("result", 4);
                head.put("message", "order is exist");
                rs.put("head", head);
                return rs.toString();
            }
        } catch (Exception e) {
            e.printStackTrace();
            LOG.error("支付异常");
            head.put("result", 5);
            head.put("message", "cp excption");
            rs.put("head", head);
            return rs.toString();
        }
    }

    private boolean verifyAccount(String userId, String session_id) {
        LOG.error("ttyy 开始调用sidInfo接口");

        JSONObject postBody = new JSONObject();
        postBody.put("uid", userId);
        postBody.put("gameId", APP_ID);

        Map<String, String> headerMap = new HashMap<String, String>();
        headerMap.put("User-Agent", "Mozilla/5.0");
        headerMap.put("Accept-Language", "en-US,en;q=0.5");
        headerMap.put("sid", session_id);

        LOG.error("[请求参数]" + postBody.toString());
        LOG.error("[请求地址]" + serverUrl);

        String result = HttpUtils.sentPost(serverUrl, postBody.toString(), headerMap);
        LOG.error("[响应结果]" + result);

        try {
            JSONObject rsp = JSONObject.fromObject(result);
            if (rsp != null && rsp.containsKey("head")) {
                JSONObject head = rsp.getJSONObject("head");
                if (head != null && head.containsKey("result")) {
                    int rlt = head.getInt("result");
                    if (rlt == 0) {
                        return true;
                    }
                }
            }
            LOG.error("ttyy 登陆失败");
            return false;

        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常");
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }
    }


    private boolean newVerifyAccount(String userId, String session_id) {
        LOG.error("ttyynew 开始调用sidInfo接口");

        JSONObject postBody = new JSONObject();
        postBody.put("gameId", Integer.valueOf(APP_ID).intValue());
        postBody.put("uid", Integer.valueOf(userId).intValue());


        Map<String, String> headerMap = new HashMap<String, String>();

        headerMap.put("Content-Type", "application/json");
        headerMap.put("sid", session_id);

        String signStr = JSON.toJSONString(postBody) + "162d7f12d163b43b5a1a82bf01da2f16";
        LOG.error("ttyynew  signStr " + signStr);

        BASE64Encoder baseEncoder = new BASE64Encoder();
        String sign = baseEncoder.encode(MD5.md5SrcDigest(signStr));
        headerMap.put("sign", sign);

        LOG.error("ttyynew  请求参数" + postBody.toString());
        LOG.error("ttyynew  请求参数header" + JSON.toJSONString(headerMap));
        LOG.error("ttyynew  请求地址" + "https://usdk.52tt.com/server/rest/user/loginstatus.view");

        String result = HttpUtils.sentPost("https://usdk.52tt.com/server/rest/user/loginstatus.view", postBody.toString(), headerMap);
        LOG.error("ttyynew  响应结果" + result);
        try {
            JSONObject rsp = JSONObject.fromObject(result);
            if (rsp != null && rsp.containsKey("head")) {
                JSONObject head = rsp.getJSONObject("head");
                if (head != null && head.containsKey("result")) {
                    int rlt = head.getInt("result");
                    if (rlt == 0) {
                        return true;
                    }
                }
            }
            LOG.error("ttyynew  登陆失败");
            return false;

        } catch (Exception e) {
            LOG.error("ttyy new  接口返回异常");
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("ttyy new  调用sidInfo接口结束");
        }
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return null;
    }

    @Override
    public String order(WebRequest request, String content) {
        try {
            LOG.error("ttyynew 获取订单");

            com.alibaba.fastjson.JSONObject json = new com.alibaba.fastjson.JSONObject();

            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                if ("plat".equals(paramName)) {
                    continue;
                }
                String val = request.getParameter(paramName);
                if (paramName.equals("gameId") || paramName.equals("userId")) {
                    json.put(paramName, Integer.valueOf(val));
                } else if (paramName.equals("cpFee")) {
                    json.put(paramName, Float.valueOf(val));
                } else {
                    json.put(paramName, val);
                }
                LOG.error(paramName + ":" + request.getParameter(paramName));
            }
            LOG.error("ttyynew结束参数 " + json.toJSONString());

            if (json.size() == 0) {
                return "param is null";
            }

            String md5Str = json.toJSONString() + "6b8e8f830dfa2b3133e2fb9c15ae5fd2";
            Map<String, String> headerMap = new HashMap<String, String>();

            headerMap.put("Content-Type", "application/json");
            BASE64Encoder baseEncoder = new BASE64Encoder();
            String sign = baseEncoder.encode(MD5.md5SrcDigest(md5Str));
            headerMap.put("sign", sign);

            String result = HttpUtils.sentPost("https://usdk.52tt.com/server/rest/recharge/order.view", json.toString(), headerMap);
            LOG.error("ttyynew  响应结果" + result);
            JSONObject rsp = JSONObject.fromObject(result);

            //{"body":{"ts":"0987681b0d9a92b1c8c96da03f21ff3d"},"head":{"message":"SUCCESS","result":"0"}}

            if (rsp != null && rsp.containsKey("head")) {
                JSONObject head = rsp.getJSONObject("head");
                if (head != null && head.containsKey("result")) {
                    int rlt = head.getInt("result");
                    if (rlt == 0) {
                        JSONObject body = rsp.getJSONObject("body");
                        return body.getString("ts");
                    }
                }
            }

            return "null";
        } catch (NumberFormatException e) {
            e.printStackTrace();
            return "null";
        }

    }

	/*public static void main(String[] args) {

		LOG.error("ttyynew 开始调用sidInfo接口");

		JSONObject postBody = new JSONObject();
		postBody.put("gameId", 201508695);
		postBody.put("uid", 5917634);


		Map<String, String> headerMap = new HashMap<String, String>();

		headerMap.put("Content-Type", "application/json");
		headerMap.put("sid", "TT3RDTK_TT_4B615360F168AEBFBF1F78C279D88D77");

		String signStr = JSON.toJSONString(postBody)+"162d7f12d163b43b5a1a82bf01da2f16";
		LOG.error("ttyynew  signStr " +signStr);

		BASE64Encoder baseEncoder = new BASE64Encoder();
		String sign = baseEncoder.encode(MD5.md5SrcDigest(signStr));
		headerMap.put("sign", sign);

		LOG.error("ttyynew  请求参数" + postBody.toString());
		LOG.error("ttyynew  请求参数header" + JSON.toJSONString(headerMap));
		LOG.error("ttyynew  请求地址" + "https://usdk.52tt.com/server/rest/user/loginstatus.view");

		String result = HttpUtils.sentPost("https://usdk.52tt.com/server/rest/user/loginstatus.view", postBody.toString(), headerMap);
		LOG.error("ttyynew  响应结果" + result);




	}*/
}
