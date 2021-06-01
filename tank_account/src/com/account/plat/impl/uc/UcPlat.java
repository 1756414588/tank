package com.account.plat.impl.uc;

import java.net.URLDecoder;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;
import java.util.TreeMap;

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

class UcAccount {
    public String ucid;
    public String nickName;
}

@Component
public class UcPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";
    // 游戏合作商编号
    private static String cpId;
    // 游戏编号
    private static String gameId;

    // 分配给游戏合作商的接入密钥,请做好安全保密
    private static String API_KEY = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/uc/", "plat.properties");
        // if (properties != null) {
        cpId = properties.getProperty("CP_ID");
        API_KEY = properties.getProperty("API_KEY");
        gameId = properties.getProperty("GAME_ID");
        serverUrl = properties.getProperty("VERIRY_URL");
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

        UcAccount ucAccount = verifyAccount(sid);
        if (ucAccount == null) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), String.valueOf(ucAccount.ucid));
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(String.valueOf(ucAccount.ucid));
            account.setAccount(getPlatNo() + "_" + String.valueOf(ucAccount.ucid));
            account.setPasswd(String.valueOf(ucAccount.ucid));
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
        response.setUserInfo(ucAccount.ucid);


        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }

    //	@Override
//	public String order(WebRequest request, String content) {
//		LOG.error("order uc");
//		LOG.error("[接收到的参数]" + content);
//		try {
//			Iterator<String> iterator = request.getParameterNames();
//			Map<String, String> params = new HashMap<String, String>();
//			while (iterator.hasNext()) {
//				String paramName = iterator.next();
//				LOG.error(paramName + ":" + request.getParameter(paramName));
//				params.put(paramName, URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
//			}
//			LOG.error("[参数结束]");
//			TreeMap<String, String> signMap = new TreeMap<String, String>(params);
//			StringBuilder stringBuilder = new StringBuilder();
//			for (Map.Entry<String, String> entry : signMap.entrySet()) {
//				// sgin和signType不参与签名
//				if ("sign".equals(entry.getKey()) || "signType".equals(entry.getKey())) {
//					continue;
//				}
//				// 值为null的参数不参与签名
//				if (entry.getValue() != null) {
//					stringBuilder.append(entry.getKey()).append("=").append(entry.getValue());
//				}
//			}
//			// 拼接签名秘钥
//			stringBuilder.append(API_KEY);
//			// 剔除参数中含有的'&'符号
//			String signSrc = stringBuilder.toString().replaceAll("&", "");
//			return MD5.md5Digest(signSrc).toLowerCase();
//		} catch (Exception e) {
//			e.printStackTrace();
//			return "FAILURE";
//		}
//	}
//	
    @Override
    public String order(WebRequest request, String content) {
        LOG.error("order chYhUc");
        LOG.error("[接收到的参数]" + content);
        try {
            Iterator<String> iterator = request.getParameterNames();
            Map<String, String> params = new HashMap<String, String>();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + request.getParameter(paramName));
                params.put(paramName, URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
            }
            LOG.error("[参数结束]");
            TreeMap<String, String> signMap = new TreeMap<String, String>(params);
            StringBuilder stringBuilder = new StringBuilder();
            for (Map.Entry<String, String> entry : signMap.entrySet()) {
                // sgin和signType不参与签名
                if ("sign".equals(entry.getKey()) || "signType".equals(entry.getKey()) || "plat".equals(entry.getKey())) {
                    continue;
                }
                // 值为null的参数不参与签名
                if (entry.getValue() != null) {
                    stringBuilder.append(entry.getKey()).append("=").append(entry.getValue());
                }
            }
            // 拼接签名秘钥
            stringBuilder.append(API_KEY);
            // 剔除参数中含有的'&'符号
            String signSrc = stringBuilder.toString().replaceAll("&", "");
            LOG.error("[签名原串]" + signSrc);
            String sign = MD5.md5Digest(signSrc).toLowerCase();
            LOG.error("[签名结果]" + sign);
            return sign;
        } catch (Exception e) {
            e.printStackTrace();
            return "FAILURE";
        }
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay uc");
        LOG.error("[接收到的参数]" + content);
        try {

            JSONObject json = JSONObject.fromObject(content);

            String sign = json.getString("sign");
            JSONObject data = json.getJSONObject("data");

            String orderId = data.getString("orderId");
            String gameId = data.getString("gameId");
            String accountId = data.getString("accountId");
            String creator = data.getString("creator");
            String payWay = data.getString("payWay");
            String amount = data.getString("amount");
            String callbackInfo = data.getString("callbackInfo");
            String orderStatus = data.getString("orderStatus");
            String failedDesc = data.getString("failedDesc");
            if (!"S".equals(orderStatus)) {
                return "SUCCESS";
            }

            LOG.error("orderId:" + orderId);
            LOG.error("gameId:" + gameId);
            LOG.error("accountId:" + accountId);
            LOG.error("creator:" + creator);
            LOG.error("payWay:" + payWay);
            LOG.error("amount:" + amount);
            LOG.error("callbackInfo:" + callbackInfo);
            LOG.error("orderStatus:" + orderStatus);
            LOG.error("failedDesc:" + failedDesc);

            StringBuffer signSource = new StringBuffer();

            signSource.append("accountId=");
            signSource.append(accountId);
            signSource.append("amount=");
            signSource.append(amount);
            signSource.append("callbackInfo=");
            signSource.append(callbackInfo);


            LOG.error("[签名原文]" + signSource.toString());
            if (data.containsKey("cpOrderId")) {

                String cpOrderId = data.getString("cpOrderId");
                signSource.append("cpOrderId=");
                signSource.append(cpOrderId);
            }

            LOG.error("[签名原文]" + signSource.toString());

            signSource.append("creator=").append(creator).append("failedDesc=").append(failedDesc).append("gameId=").append(gameId);
            signSource.append("orderId=").append(orderId).append("orderStatus=").append(orderStatus).append("payWay=").append(payWay);
            signSource.append(API_KEY);

            String orginSign = MD5.md5Digest(signSource.toString());
            LOG.error("[签名原文]" + signSource.toString());
            LOG.error("[签名结果]" + orginSign + " | " + sign);
            if (orginSign.equals(sign)) {
                String[] infos = callbackInfo.split("_");
                if (infos.length != 3) {
                    return "FAILURE";
                }
                int serverid = Integer.valueOf(infos[0]);
                Long lordId = Long.valueOf(infos[1]);

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.platId = accountId;
                payInfo.orderId = orderId;

                payInfo.serialId = callbackInfo;
                payInfo.serverId = serverid;
                payInfo.roleId = lordId;
                payInfo.realAmount = Double.valueOf(amount);
                payInfo.amount = (int) (payInfo.realAmount / 1);
                int code = payToGameServer(payInfo);
                if (code != 0) {
                    LOG.error("uc 充值发货失败！！ " + code);
                    return "FAILURE";
                }
                return "SUCCESS";
            } else {
                return "FAILURE";
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "FAILURE";
        }
    }

    private UcAccount verifyAccount(String sid) {
        LOG.error("uc开始调用sidInfo接口");
        JSONObject params = new JSONObject();
        params.put("id", System.currentTimeMillis());

        JSONObject data = new JSONObject();
        data.put("sid", sid);
        params.put("data", data);

        JSONObject game = new JSONObject();
        game.put("gameId", Integer.valueOf(gameId));
        params.put("game", game);

        String signSource = "sid=" + sid + API_KEY;// 组装签名原文
        String sign = MD5.md5Digest(signSource).toLowerCase();

        LOG.error("[签名原文]" + signSource);
        LOG.error("[签名结果]" + sign);

        params.put("sign", sign);

        String body = params.toString();
        LOG.error("[请求地址]" + serverUrl);
        LOG.error("[请求参数]" + body);

        String result = HttpUtils.sentPost(serverUrl, body);
        // post方式调用服务器接口,请求的body内容是参数json格式字符串
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

        UcAccount ucAccount = new UcAccount();

        try {
            JSONObject rsp = JSONObject.fromObject(result);
            JSONObject state = rsp.getJSONObject("state");
            int code = state.getInt("code");
            if (code == 1) {
                JSONObject rspData = rsp.getJSONObject("data");
                ucAccount.ucid = rspData.getString("accountId");
                ucAccount.nickName = rspData.getString("nickName");
                LOG.error("[ucid]" + ucAccount.ucid);
                LOG.error("[nickName]" + ucAccount.nickName);
                return ucAccount;
            } else {
                String msg = state.getString("msg");
                LOG.error("uc登陆失败:" + code);
                LOG.error("[msg]" + msg);
                return null;
            }

        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常");
            e.printStackTrace();
        } finally {
            LOG.error("调用sidInfo接口结束");
        }

        return null;
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }
}
