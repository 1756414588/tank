package com.account.plat.impl.chYh360;

import java.net.URLDecoder;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.omg.CosNaming.NamingContextExtPackage.StringNameHelper;
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

//class UcAccount {
//	public int ucid;
//	public String nickName;
//}

@Component
public class ChYh360Plat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
//	private static String AppID;

//	private static String AppKey;

    private static String AppSecret;

    // 分配给游戏合作商的接入密钥,请做好安全保密
    // private static String SecretKey = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chYh360/", "plat.properties");
//		AppID = properties.getProperty("AppID");
//		AppKey = properties.getProperty("AppKey");
        AppSecret = properties.getProperty("AppSecret");
        serverUrl = properties.getProperty("VERIRY_URL");
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
        if (vParam.length < 1) {
            return GameError.PARAM_ERROR;
        }

        String userId = verifyAccount(vParam[0]);
        if (userId == null) {
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

    public static String getSignStr(Map<String, String> params) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;

        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("plat") || k.equals("sign_return") || k.equals("sign")) {
                continue;
            }

            if (params.get(k) == null || params.get(k).equals("") || params.get(k).equals("0")) {
                continue;
            }
            v = (String) params.get(k);

            if (str.equals("")) {
                str = v;
            } else {
                str = str + "#" + v;
            }
        }
        return str;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay chYh360");
        try {
            LOG.error("pay chYh360 content:" + content);
            LOG.error("[开始参数]");
            Iterator<String> iterator = request.getParameterNames();
            Map<String, String> params = new HashMap<>();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
                params.put(paramName, URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
            }
            LOG.error("[结束参数]");

            String app_key = request.getParameter("app_key");
            String product_id = request.getParameter("product_id");
            String amount = request.getParameter("amount");
            String app_uid = request.getParameter("app_uid");
            String app_ext1 = request.getParameter("app_ext1");
            String app_ext2 = request.getParameter("app_ext2");
            String user_id = request.getParameter("user_id");
            String order_id = request.getParameter("order_id");
            String gateway_flag = request.getParameter("gateway_flag");
            String sign_type = request.getParameter("sign_type");
            String app_order_id = request.getParameter("app_order_id");
            String sign_return = request.getParameter("sign_return");
            String sign = request.getParameter("sign");

            String signStr = getSignStr(params) + "#" + AppSecret;
            LOG.error("[签名原文]" + signStr);
            String signCheck = MD5.md5Digest(signStr);
            LOG.error("[签名结果]" + signCheck);

            if (!sign.equals(signCheck)) {  // 签名失败
                LOG.error("chYh360 sign error");
                return getResult("ok", "other", "sign error");
            }

            if (!gateway_flag.equals("success")) {  // 支付返回不成功
                LOG.error("chYh360 error gateway_flag:" + gateway_flag);
                return getResult("ok", "other", "gateway_flag:" + gateway_flag);
            }

            String[] v = app_ext1.split("_");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = user_id;
            payInfo.orderId = order_id;

            payInfo.serialId = app_ext1;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(amount) / 100;
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                if (code == 2) {
                    LOG.error("chYh360 充值发货失败！！ " + code);
                } else if (code == 1) {
                    LOG.error("chYh360 重复的订单号！！ " + code);
                }
                return getResult("ok", "other", "notice gameServer code:" + code);
            }
            LOG.error("chYh360 充值发货成功 ");
            return getResult("ok", "success", "");
        } catch (Exception e) {
            LOG.error("chYh360 充值异常:" + e.getMessage());
            e.printStackTrace();
            return getResult("ok", "other", "exception");
        }
    }

    private String getResult(String status, String delivery, String msg) {
        JSONObject result = new JSONObject();
        result.put("status", status);
        result.put("delivery", delivery);
        result.put("msg", msg);
        return result.toString();
    }


    private String verifyAccount(String token) {
        LOG.error("chYh360 开始调用sidInfo接口");
        String url = serverUrl + "access_token=" + token;
        LOG.error("[请求url]" + url);
        try {
            String result = HttpUtils.sendGet(url, new HashMap<String, String>());
            LOG.error("[响应结果]" + result);
            JSONObject rsp = JSONObject.fromObject(result);
            return rsp.getString("id");  // 360用户id
        } catch (Exception e) {
            LOG.error("chYh360 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }
    }

}
