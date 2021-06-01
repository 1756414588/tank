package com.account.plat.impl.huashuo;

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
public class HuashuoPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static String APP_ID;

    private static String APP_KEY = "";

    private static String APP_SECRET = "";

    // private static String PAY_KEY = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/huashuo/", "plat.properties");
        // if (properties != null) {
        APP_ID = properties.getProperty("APP_ID");
        APP_KEY = properties.getProperty("APP_KEY");
        APP_SECRET = properties.getProperty("APP_SECRET");
        // PAY_KEY = properties.getProperty("PAY_KEY");
        serverUrl = properties.getProperty("VERIRY_URL");
        // }
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

        String[] vParam = sid.split("_");
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String roleId = vParam[0];
        String sessionId = vParam[1];
        if (!verifyAccount(roleId, sessionId)) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), roleId);

        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(roleId);
            account.setAccount(getPlatNo() + "_" + roleId);
            account.setPasswd(roleId);
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
        LOG.error("pay huashuo");
        try {
            LOG.error("[开始接收参数]");
            Map<String, String> params = new HashMap<String, String>();
            Iterator<String> it = request.getParameterNames();
            while (it.hasNext()) {
                String paramKey = it.next();
                String paramValue = request.getParameter(paramKey);
                LOG.error(paramKey + "=" + paramValue);
                params.put(paramKey, paramValue);
            }
            LOG.error("[结束接收参数]");
            String appid = request.getParameter("appid");

            String cpexinfo = request.getParameter("cpexinfo");
            String cporderid = request.getParameter("cporderid");

            String orderid = request.getParameter("orderid");
            String orderstatus = request.getParameter("orderstatus");

            String payfee = request.getParameter("payfee");
            String paytime = request.getParameter("paytime");
            String productcode = request.getParameter("productcode");
            String productcount = request.getParameter("productcount");
            String productname = request.getParameter("productname");

            String roleid = request.getParameter("roleid");

            String sign = request.getParameter("sign");

//			String signNation = "appid=" + appid + "&cpexinfo=" + cpexinfo + "&cporderid=" + cporderid + "&orderid=" + orderid + "&orderstatus=" + orderstatus +
//
//			"&payfee=" + payfee + "&paytime=" + paytime + "&productcode=" + productcode + "&productcount=" + productcount + "&productname=" + productname
//					+ "&roleid=" + roleid + "&key=" + APP_SECRET;

            String signNation = getSignNation(params) + "&key=" + APP_SECRET;

            if (!"2".equals(orderstatus)) {
                LOG.error("扣费不成功");
                return "failure";
            }

            String tosign = MD5.md5Digest(signNation);
            LOG.error("[签名原文]" + signNation);
            LOG.error("[签名结果]" + sign + "|" + tosign);

            if (!sign.equals(tosign)) {
                LOG.error("验签失败");
                return "failure";
            }

            String[] infos = cporderid.split("_");
            if (infos.length != 3) {
                LOG.error("传参不正确");
                return "failure";
            }
            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = roleid;
            payInfo.orderId = orderid;

            payInfo.serialId = cporderid;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(payfee) / 10.0;
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int retcode = payToGameServer(payInfo);
            if (retcode == 0) {
                LOG.error("返回充值成功");
                return "success";
            } else {
                LOG.error("返回充值失败");
                return "success";
            }
        } catch (Exception e) {
            e.printStackTrace();
            LOG.error("支付异常:" + e.getMessage());
            return "failure";
        }
    }

    public static String getSignNation(Map<String, String> params) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;

        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("sign") || k.equals("plat")) {
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

    private boolean verifyAccount(String roleid, String roletoken) {
        LOG.error("huashuo 开始调用sidInfo接口");

        String signNation = "appid=" + APP_ID + "&roleid=" + roleid + "&roletoken=" + roletoken + "&key=" + APP_SECRET;
        String sign = MD5.md5Digest(signNation);
        LOG.error("[签名原文]" + signNation);
        LOG.error("[签名结果]" + sign);

        Map<String, String> parameter = new HashMap<>();
        parameter.put("appid", APP_ID);
        parameter.put("apptoken", APP_KEY);
        parameter.put("roleid", roleid);
        parameter.put("roletoken", roletoken);
        parameter.put("sign", sign);

        LOG.error("[请求参数]" + parameter.toString());
        LOG.error("[请求地址]" + serverUrl);

        String result = HttpUtils.sendGet(serverUrl, parameter);
        LOG.error("[响应结果]" + result);

        try {
            JSONObject rsp = JSONObject.fromObject(result);
            int rescode = rsp.getInt("rescode");
            if (rescode == 0) {
                return true;
            }
            String resmsg = rsp.getString("resmsg");
            LOG.error("huashuo 登陆失败:" + rescode + "|" + resmsg);
            return false;

        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return null;
    }

}
