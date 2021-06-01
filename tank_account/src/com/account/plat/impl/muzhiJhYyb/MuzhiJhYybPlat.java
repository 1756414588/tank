package com.account.plat.impl.muzhiJhYyb;

import java.net.URLEncoder;
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
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class MuzhiJhYybPlat extends PlatBase {
    // sdk server的接口地址
    private static String VERIRY_URL = "";

    private static String APP_KEY;

    private static String APP_ID;

    private static String method = "get";

    private static String PAY_APP_KEY;

    private static String PRIVATE_KEY;
    private static String PUBLIC_KEY;
    private static String TEST_URL;

    // private static String CHECK_URL;
    //
    // private static String COST_URL;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/muzhiJhYyb/", "plat.properties");
        // if (properties != null) {
        APP_KEY = properties.getProperty("APP_KEY");
        APP_ID = properties.getProperty("APP_ID");
        VERIRY_URL = properties.getProperty("VERIRY_URL");
        PAY_APP_KEY = properties.getProperty("PAY_APP_KEY");
        PRIVATE_KEY = properties.getProperty("PRIVATE_KEY");
        PUBLIC_KEY = properties.getProperty("PUBLIC_KEY");
        TEST_URL = properties.getProperty("TEST_URL");
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

        String[] vParam = sid.split("_");
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[0];// userId
        String usertoken = vParam[1];// token

        if (!verifyAccount(userId, usertoken)) {
            return GameError.SDK_LOGIN;
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
    public String order(WebRequest request, String content) {
        LOG.error("pay muzhiJhYyb order");
        JSONObject rets = new JSONObject();
        rets.put("result", 0);
        try {
            String url = VERIRY_URL + "/pay/getOrderID";
//			String url = TEST_URL + "/pay/getOrderID";// 测试URL

            String userID = request.getParameter("userID");
            String productID = request.getParameter("productID");
            String productName = request.getParameter("productName");
            String productDesc = request.getParameter("productDesc");
            String money = request.getParameter("money");
            String roleID = request.getParameter("roleID");
            String roleName = request.getParameter("roleName");
            String serverID = request.getParameter("serverID");
            String serverName = request.getParameter("serverName");
            String extension = request.getParameter("extension");

            // productDesc = URLEncoder.encode(productDesc);
            // roleName = URLEncoder.encode(roleName);
            // serverName = URLEncoder.encode(serverName);

            StringBuffer sb = new StringBuffer();
            sb.append("userID=").append(userID).append("&");
            sb.append("productID=").append(productID).append("&");
            sb.append("productName=").append(productName).append("&");
            sb.append("productDesc=").append(productDesc).append("&");
            sb.append("money=").append(Integer.valueOf(money) * 100).append("&");
            sb.append("roleID=").append(roleID).append("&");
            sb.append("roleName=").append(roleName).append("&");
            sb.append("serverID=").append(serverID).append("&");
            sb.append("serverName=").append(serverName).append("&");
            sb.append("extension=").append(extension).append(APP_KEY);

            String signNation = sb.toString();
            LOG.error("订单签名原文:" + signNation);

            String encode = URLEncoder.encode(signNation, "UTF-8");
            String sign = RSAUtils.sign(encode, PRIVATE_KEY, "UTF-8");

            Map<String, String> param = new HashMap<String, String>();
            param.put("userID", userID);
            param.put("productID", productID);
            param.put("productName", productName);
            param.put("productDesc", productDesc);
            param.put("money", String.valueOf(Integer.valueOf(money) * 100));
            param.put("roleID", roleID);
            param.put("roleName", roleName);
            param.put("serverID", serverID);
            param.put("serverName", serverName);
            param.put("extension", extension);
            param.put("sign", sign);

            String result = U8HttpUtils.httpPost(url, param);
            String body = param.toString();
            LOG.error("[请求参数]" + body);
            LOG.error("[响应结果]" + result);
            JSONObject ret = JSONObject.fromObject(result);
            int state = ret.getInt("state");
            if (state == 1) {
                JSONObject data = ret.getJSONObject("data");
                rets.put("orderID", data.getString("orderID"));
                rets.put("extension", data.getString("extension"));
                rets.put("result", state);
            }
        } catch (Exception e) {
            e.printStackTrace();
            rets.put("result", 2);
        }
        return rets.toString();
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay muzhiJhYyb");
        LOG.error("[接收到的参数]" + content);
        content = new String(Base64.decode(content));
        LOG.error("[接收到的参数]" + content);
        try {
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + request.getParameter(paramName));
            }

            JSONObject param = JSONObject.fromObject(content);
            int state = param.getInt("state");
            if (state <= 1) {
                LOG.error("[支付状态异常 ] state:" + state);
                return "FAIL";
            }
            String sign = param.getString("sign");
//			JSONObject data = param.getJSONObject("data");
            String orderID = param.getString("orderID");
            int userID = param.getInt("userID");
            int money = param.getInt("money");
            String extension = param.getString("extension");

            // String state = request.getParameter("state");
            // if (state == null || !state.equals("1")) {
            // return "FAIL";
            // }
            // String sign = request.getParameter("sign");
            // JSONObject data =
            // JSONObject.fromObject(request.getParameter("data"));
            // long orderID = data.getLong("orderID");
            // int userID = data.getInt("userID");
            // int money = data.getInt("money");
            // String extension = data.getString("extension");

//			LOG.error("[签名原文]" + data.toString());
//			LOG.error("[签名公钥]" + PUBLIC_KEY);

//			boolean flag = RSAUtils.verify(data.toString(), sign, PUBLIC_KEY, "UTF-8");
            boolean flag = sign.equals(MD5.md5Digest(orderID + money + state + APP_KEY));
            if (!flag) {
                LOG.error("[支付验签失败]");
                return "FAIL";
            }

            String[] v = extension.split("_");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = String.valueOf(userID);
            payInfo.orderId = String.valueOf(orderID);

            payInfo.serialId = extension;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(money) / 100.0;
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("muzhiJhYyb 充值发货失败！！ " + code);
            }
            return "SUCCESS";
        } catch (Exception e) {
            LOG.error("muzhiJhYyb 充值异常！！ ");
            e.printStackTrace();
            return "FAIL";
        }
    }

    private boolean verifyAccount(String userID, String token) {
        LOG.error("muzhiJhYyb开始调用sidInfo接口");
        // StringBuffer sb = new StringBuffer();
        // sb.append("APP_ID").append(APP_ID).
        String timestamp = "userID=" + userID + "token=" + token + APP_KEY;
        String sig = MD5.md5Digest(timestamp).toLowerCase();
        String url = VERIRY_URL + "/user/verifyAccount";
//		String url = TEST_URL + "/user/verifyAccount";//测试URL
        LOG.error("url: " + url);
        Map<String, String> param = new HashMap<String, String>();
        param.put("userID", userID);
        param.put("token", token);
        param.put("sign", sig);

        String result = HttpUtils.sendGet(url, param);
        // post方式调用服务器接口,请求的body内容是参数json格式字符串
        String body = param.toString();
        LOG.error("[请求参数]" + body);
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

        try {
            JSONObject rsp = JSONObject.fromObject(result);
            int ret = rsp.getInt("state");
            String data = rsp.getString("data");
            LOG.error("[ret][data]" + ret + " " + data);
            LOG.error("调用sidInfo接口结束");
            if (ret == 1) {
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

    public static void main(String[] args) {
	/*	String userID = "72";
		String token = "0842ac5ad8146da5d1239137c37a8c08";
		String appKey = "b5e1080753e506e19d76e05f99c918cc";
		String timestamp = "userID=" + userID + "token=" + token + appKey;
		String sig = MD5.md5Digest(timestamp).toLowerCase();

		LOG.error("[签名原文]" + timestamp);
		LOG.error("[签名结果]" + sig);
		// String sig = MD5.md5Digest(timestamp).toLowerCase();
		String url = "http://115.159.206.124:8080/MySDK/user/verifyAccount";
		LOG.error("url: " + url);
		Map<String, String> param = new HashMap<String, String>();
		param.put("userID", userID);
		param.put("token", token);
		param.put("sign", sig);

		String result = U8HttpUtils.httpPost(url, param);
		// post方式调用服务器接口,请求的body内容是参数json格式字符串
		String body = param.toString();
		LOG.error("[请求参数]" + body);
		LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串*/

    }

}
