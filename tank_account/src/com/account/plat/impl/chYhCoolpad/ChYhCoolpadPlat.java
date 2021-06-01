package com.account.plat.impl.chYhCoolpad;

import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
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
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class ChYhCoolpadPlat extends PlatBase {
    // sdk server的接口地址
    private static String VERIRY_URL = "";

    private static String APP_ID;

    private static String APP_KEY;

//	private static String APP_SECRET = "";

//	private static String PAY_URL = "";

//	private static String PRIVATE_KEY = "";

    private static String PUBLIC_KEY = "";

//	private String accessToken = "1.6841190312049d48d5322d5b764ffe02.4f6ef349a6188ec52410b7aaff5d3d01.1465722958516";
//	private String refreshToken = "1.de2ddbe0eb28d615cef6266c2232f7d8";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chYhCoolpad/", "plat.properties");

        VERIRY_URL = properties.getProperty("VERIRY_URL");
        APP_ID = properties.getProperty("APP_ID");
        APP_KEY = properties.getProperty("APP_KEY");
//		APP_SECRET = properties.getProperty("APP_SECRET");
//		ORDER_URL = properties.getProperty("ORDER_URL");
//		PAY_URL = properties.getProperty("PAY_URL");
//		PRIVATE_KEY = properties.getProperty("PRIVATE_KEY");
        PUBLIC_KEY = properties.getProperty("PUBLIC_KEY");
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

        // String[] param = sid.split("_");
        // String openid = param[0];
        // String accessToken = param[1];
        JSONObject ret = verifyAccount(sid);
        if (ret == null) {
            return GameError.SDK_LOGIN;
        }
        String openid = ret.getString("openid");
        String access_token = ret.getString("access_token");

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
        response.setUserInfo(openid + "&" + access_token);

        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }

    @Override
    public String order(WebRequest request, String content) {
        try {
            LOG.error("pay chYhCoolpad order");

            String code = request.getParameter("authorization_code");
            JSONObject rets = getTokenByCode(code);
            if (rets == null) {
                return null;
            }
            JSONObject result = new JSONObject();
            result.put("openid", rets.getString("openid"));
            result.put("access_token", rets.getString("access_token"));
            LOG.error("[返回参数]" + result.toString());
            return result.toString();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay chYhCoolpad");
        LOG.error("[接收到的参数]" + content);
        try {
            LOG.error("[参数开始]");
            Iterator<String> it = request.getParameterNames();
            while (it.hasNext()) {
                String p = it.next();
                String v = request.getParameter(p);
                LOG.error(p + ":" + v);
            }
            LOG.error("[参数结束]");
            String signNation = request.getParameter("transdata");
            JSONObject transdata = JSONObject.fromObject(signNation);
            String sign = request.getParameter("sign");

            String exorderno = transdata.getString("exorderno");
            String transid = transdata.getString("transid");
//			String appid = transdata.getString("transid");
//			String waresid = transdata.getString("appuserid");
            String appid = transdata.getString("appid");
            String waresid = transdata.getString("waresid");
            String count = transdata.getString("feetype");
            String money = transdata.getString("money");
//			String transtype = transdata.getString("currency");
            String result = transdata.getString("result");
            String transtime = transdata.getString("transtime");
            String cpprivate = transdata.getString("cpprivate");

            if (!result.equals("0")) {
                LOG.error("充值不成功");
                return "FAILURE";
            }

            LOG.error("[签名原文]" + signNation);
            if (!CpTransSyncSignValid.validSign(signNation, sign, PUBLIC_KEY)) {
                LOG.error("签名不正确");
                return "FAILURE";
            }

            String[] infos = cpprivate.split("_");
            if (infos.length != 4) {
                LOG.error("chYhCoolpad 传参错误");
                return "FAILURE";
            }
            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);
            String userId = infos[3];

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = userId;
            payInfo.orderId = transid;

            payInfo.serialId = cpprivate;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(money) / 100;
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);

            if (code == 0) {
                LOG.error("chYhCoolpad 返回充值成功");
                return "SUCCESS";
            } else {
                LOG.error("chYhCoolpad 返回充值失败");
                return "FAILURE";
            }

        } catch (Exception e) {
            e.printStackTrace();
            return "FAILURE";
        }
    }

    private JSONObject verifyAccount(String code) {
        LOG.error("chYhCoolpad开始调用sidInfo接口");
        return getTokenByCode(code);

    }

    public JSONObject getTokenByCode(String code) {
        HashMap<String, String> params = new HashMap<String, String>();
        params.put("grant_type", "authorization_code");
        params.put("client_id", APP_ID);
        params.put("client_secret", APP_KEY);
        params.put("code", code);
        params.put("redirect_uri", APP_KEY);

        LOG.error("[请求参数]" + params.toString());
        String result = HttpUtils.sendGet(VERIRY_URL, params);
        // post方式调用服务器接口,请求的body内容是参数json格式字符串
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串
        if (result == null) {
            return null;
        }
        try {
            JSONObject json = JSONObject.fromObject(result);
            if (json.containsKey("openid") && json.containsKey("access_token") && json.containsKey("refresh_token")) {
                return json;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
        return null;
    }
}
