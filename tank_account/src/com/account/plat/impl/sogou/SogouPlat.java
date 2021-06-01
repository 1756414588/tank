package com.account.plat.impl.sogou;

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
public class SogouPlat extends PlatBase {
    // sdk server的接口地址
    // private static String serverUrl = "";
    //
    private static String VERIRY_URL = "";

    private static String APP_ID;

    private static String APP_KEY;

    private static String APP_SECRET;

    private static String PAY_KEY;

    private static String CALLBACK_OK = "OK";

    private static String CALLBACK_FAIL = "FAIL";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/sogou/", "plat.properties");
        APP_ID = properties.getProperty("APP_ID");
        APP_KEY = properties.getProperty("APP_KEY");
        APP_SECRET = properties.getProperty("APP_SECRET");
        PAY_KEY = properties.getProperty("PAY_KEY");
        VERIRY_URL = properties.getProperty("VERIRY_URL");
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

        String session_key = vParam[0];
        String user_id = vParam[1];

        if (!verifyAccount(session_key, user_id)) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), user_id);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(user_id);
            account.setAccount(getPlatNo() + "_" + user_id);
            account.setPasswd(user_id);
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

    public static String getSignNation(Map<String, String> params) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;

        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("auth")) {
                continue;
            }

            if (params.get(k) == null) {
                continue;
            }
            v = (String) params.get(k);

            if (str.equals("")) {
                str = k + "=" + v;
            } else {
                str = str + "&" + k + "=" + v;
            }
        }
        return str;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay sogou");
        try {
            LOG.error("[接收参数开始]");
            Iterator<String> it = request.getParameterNames();
            Map<String, String> params = new HashMap<String, String>();
            while (it.hasNext()) {
                String paramKey = it.next();
                String paramValue = request.getParameter(paramKey);
                LOG.error(paramKey + "=" + paramValue);
                params.put(paramKey, paramValue);
            }
            LOG.error("[接收参数结束]");

            String gid = request.getParameter("gid");
            String sid = request.getParameter("sid");
            String uid = request.getParameter("uid");
            String role = request.getParameter("role");
            String oid = request.getParameter("oid");
            String date = request.getParameter("date");
            String amount1 = request.getParameter("amount1");
            String amount2 = request.getParameter("amount2");
            String time = request.getParameter("time");
            String appdata = request.getParameter("appdata");
            String realAmount = request.getParameter("realAmount");
            String plat = request.getParameter("plat");
            String auth = request.getParameter("auth");

//			StringBuffer sb = new StringBuffer();
//			sb.append("amount1=").append(amount1).append("&");
//			sb.append("amount2=").append(amount2).append("&");
//			sb.append("appdata=").append(appdata).append("&");
//			sb.append("date=").append(date).append("&");
//			sb.append("gid=").append(gid).append("&");
//			sb.append("oid=").append(oid).append("&");
//			sb.append("plat=").append(plat).append("&");
//			sb.append("realAmount=").append(realAmount).append("&");
//			sb.append("role=").append(role).append("&");
//			sb.append("sid=").append(sid).append("&");
//			sb.append("time=").append(time).append("&");
//			sb.append("uid=").append(uid).append("&");
//			sb.append(PAY_KEY);

//			String signNation1 = sb.toString();
            String signNation = getSignNation(params) + "&" + PAY_KEY;

//			LOG.error("[签名原文]" + signNation1);
            LOG.error("[签名原文]" + signNation);
            String sign = MD5.md5Digest(signNation);
            LOG.error("[签名结果]" + auth + "|" + sign);
            if (!auth.equals(sign)) {
                LOG.error("签名验证失败");
                return CALLBACK_FAIL;
            }

            String[] v = appdata.split("_");
            if (v.length != 3) {
                LOG.error("参数错误");
                return CALLBACK_OK;
            }

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = uid;
            payInfo.orderId = oid;

            payInfo.serialId = appdata;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(realAmount);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code == 0) {
                LOG.error("sogou 充值发货成功 ");
            } else {
                LOG.error("sogou 充值发货失败！！ " + code);
            }
            return CALLBACK_OK;
        } catch (Exception e) {
            e.printStackTrace();
            return CALLBACK_FAIL;
        }
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.PARAM_ERROR;
    }

    private boolean verifyAccount(String session_key, String user_id) {
        LOG.error("sougou开始调用sidInfo接口");
        try {
            StringBuffer sb = new StringBuffer();
            sb.append("gid=").append(APP_ID).append("&");
            sb.append("session_key=").append(session_key).append("&");
            sb.append("user_id=").append(user_id).append("&");
            sb.append(APP_SECRET);
            String signNation = sb.toString();
            String sign = MD5.md5Digest(signNation);
            LOG.error("[签名原文]" + signNation);
            LOG.error("[签名结果]" + sign);

            String body = "gid=" + APP_ID + "&session_key=" + session_key + "&user_id=" + user_id + "&auth=" + sign;
            String url = VERIRY_URL + "/api/v1/login/verify";
            LOG.error("[请求URL]" + url);
            LOG.error("[请求参数]" + body);

            String result = HttpUtils.sentPost(url, body);
            LOG.error("[响应结果]" + result);
            JSONObject ret = JSONObject.fromObject(result);
            if (ret != null && ret.containsKey("result")) {
                return ret.getBoolean("result");
            } else {
                LOG.error("[sougou玩登录失败]");
                return false;
            }
        } catch (Exception e) {
            // TODO: handle exception
            e.printStackTrace();
            return false;
        }
    }

    public static void main(String[] args) {
        String signNation = "amount1=10&amount2=0&appdata=1_132463_1456819037419&date=160301&gid=1538&oid=P160301_13356005&plat=sogou&realAmount=10&role=&sid=1&time=20160301155732&uid=64516950&{5ACDE841-4B0B-459B-BB11-A3531B5D102B}";
        //LOG.error(MD5.md5Digest(signNation));
    }
}
