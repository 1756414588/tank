package com.account.plat.impl.muzhi49;

import java.util.Date;
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
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class Muzhi49Plat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    private static String APP_KEY;

    private static String APP_ID;

    private static String SECRET_KEY;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/muzhi49/", "plat.properties");
        APP_KEY = properties.getProperty("APP_KEY");
        APP_ID = properties.getProperty("APP_ID");
        SECRET_KEY = properties.getProperty("SECRET_KEY");
        serverUrl = properties.getProperty("VERIRY_URL");

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
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String uid = vParam[0];
        String accessToken = vParam[1];

        if (!verifyAccount(uid, accessToken)) {
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

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay 49you");
        LOG.error("[接收到的参数]" + content);
        try {
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + request.getParameter(paramName));
            }

            String orderId = request.getParameter("orderId");
            String uid = request.getParameter("uid");
            String amount = request.getParameter("amount");
            String serverId = request.getParameter("serverId");
            String extraInfo = request.getParameter("extraInfo");
            String sign = request.getParameter("sign");

            LOG.error("[参数结束]");
            String signStr = orderId + uid + serverId + amount + extraInfo + SECRET_KEY;
            String isign = MD5.md5Digest(signStr).toLowerCase();

            LOG.error("签名：" + isign + " | " + sign);
            if (!sign.equals(isign)) {
                LOG.error("签名失败");
                return "sign";
            }

            String[] v = extraInfo.split("_");
            if (v.length != 3) {
                LOG.error("参数长度错误");
                return "sign";
            }

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = uid;
            payInfo.orderId = orderId;
            payInfo.serialId = extraInfo;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(amount);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code == 0) {
                LOG.error("发货成功 " + code);
                return "success";
            } else if (code == 1) {
                LOG.error("订单号已存在 " + code);
                return "exist";
            } else if (code == 2) {
                LOG.error("serverId不正确" + code);
                return "serverid";
            }
        } catch (Exception e) {
            LOG.error("充值异常:" + e.getMessage());
            e.printStackTrace();
            return "serverid";
        }
        return "wait";
    }

    private boolean verifyAccount(String uid, String accessToken) {
        LOG.error("49you开始调用sidInfo接口");
        long timestamp = System.currentTimeMillis() / 1000L;
        String signStr = APP_ID + uid + accessToken + timestamp + SECRET_KEY;
        String sign = MD5.md5Digest(signStr).toLowerCase();
        LOG.error("[签名原文]" + signStr);
        LOG.error("[签名结果]" + sign);

        String body = "appid=" + APP_ID + "&uid=" + uid + "&token=" + accessToken + "&time=" + timestamp + "&sign=" + sign;
        LOG.error("[body]" + body);

        String result = HttpUtils.sentPost(serverUrl, body);
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

        try {
            if ("success".equals(result)) {
                return true;
            }
        } catch (Exception e) {
            LOG.error("接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        }
        return false;
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
