package com.account.plat.impl.chYh;

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
public class ChYhPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static String GameId;

    private static String AppKey;

    private static String ServerKey;

    // 分配给游戏合作商的接入密钥,请做好安全保密
    // private static String SecretKey = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chYh/", "plat.properties");
        GameId = properties.getProperty("GameId");
        AppKey = properties.getProperty("AppKey");
        // SecretKey = properties.getProperty("SecretKey");
        serverUrl = properties.getProperty("VERIRY_URL");
        ServerKey = properties.getProperty("ServerKey");
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

        String[] vParam = sid.split(",");
        if (vParam.length < 6) {
            return GameError.PARAM_ERROR;
        }

        // String sourceId = vParam[0];
        // String deviceId = vParam[1];
        // String chDeviceNo = vParam[2];
        String userId = vParam[3];
        // String userName = vParam[4];
        // String token = vParam[5];

        String backStr = verifyAccount(vParam);
        if (backStr == null) {
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
        response.setUserInfo(backStr);

        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }

    @Override
    public String newPayBack(WebRequest request, String content,
                             HttpServletResponse response, String type) {
        LOG.error("pay chYh");
        LOG.error("[接收到的参数]" + content);
        try {
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + request.getParameter(paramName));
            }

            String OrderNo = request.getParameter("OrderNo");
            String OutPayNo = request.getParameter("OutPayNo");
            String UserID = request.getParameter("UserID");
            String ServerNo = request.getParameter("ServerNo");
            String PayType = request.getParameter("PayType");
            String Money = request.getParameter("Money");
            String PMoney = request.getParameter("PMoney");
            String PayTime = request.getParameter("PayTime");
            String Sign = request.getParameter("Sign");

            //MD5(OrderNo+OutPayNo+UserID+ServerNo+PayType+Money+PMoney+ PayTime+ServerKey)

            String signSource = OrderNo + OutPayNo + UserID + ServerNo + PayType + Money + PMoney + PayTime + ServerKey;// 组装签名原文
            String sign = MD5.md5Digest(signSource).toUpperCase();
            LOG.error("[签名原文]" + signSource);
            LOG.error("[签名结果]" + sign);

            if (!sign.equals(Sign)) {
                LOG.error("chYh sign error");
                return "0";
            }

            String[] v = OutPayNo.split("_");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = UserID;
            payInfo.orderId = OrderNo;

            payInfo.serialId = OutPayNo;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(Money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("chYh 充值发货失败！！ " + code);
                return "0";
            }
            LOG.error("chYh 充值发货成功！！ " + code);
            return "1";
        } catch (Exception e) {
            LOG.error("chYh 充值异常:" + e.getMessage());
            e.printStackTrace();
            return "1";
        }
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay chYh");
        try {
            LOG.error("[开始参数]");
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + request.getParameter(paramName));
            }
            LOG.error("[结束参数]");

            String OrderNo = request.getParameter("OrderNo");
            String OutPayNo = request.getParameter("OutPayNo");
            String UserID = request.getParameter("UserID");
            String ServerNo = request.getParameter("ServerNo");
            String PayType = request.getParameter("PayType");
            String Money = request.getParameter("Money");
            String PMoney = request.getParameter("PMoney");
            String PayTime = request.getParameter("PayTime");
            String Sign = request.getParameter("Sign");

            // MD5(OrderNo+OutPayNo+UserID+ServerNo+PayType+Money+PMoney+
            // PayTime+ GameKey)

            String signSource = OrderNo + OutPayNo + UserID + ServerNo + PayType + Money + PMoney + PayTime + AppKey;// 组装签名原文
            String sign = MD5.md5Digest(signSource).toUpperCase();
            LOG.error("[签名原文]" + signSource);
            LOG.error("[签名结果]" + sign + "|" + Sign);

            if (!sign.equals(Sign)) {
                LOG.error("chYh sign error");
                return "0|" + (System.currentTimeMillis() / 1000);
            }

            // serverId_roleId_timeStamp
            String[] v = OutPayNo.split("_");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = UserID;
            payInfo.orderId = OrderNo;

            payInfo.serialId = OutPayNo;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(Money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("chYh 充值发货失败！！ " + code);
                return "0|" + (System.currentTimeMillis() / 1000);
            }
            LOG.error("chYh 充值发货成功 ");
            return "1|" + (System.currentTimeMillis() / 1000);
        } catch (Exception e) {
            LOG.error("chYh 充值异常:" + e.getMessage());
            e.printStackTrace();
            return "0|" + (System.currentTimeMillis() / 1000);
        }
    }

    // public static void main(String[] args) {
    // LOG.error("1|" + System.currentTimeMillis());
    // }
    // String sourceId = vParam[0];
    // String deviceId = vParam[1];
    // String chDeviceNo = vParam[2];
    // String userId = vParam[3];
    // String userName = vParam[4];
    // String token = vParam[5];

    private String verifyAccount(String[] param) {
        LOG.error("chYh 开始调用sidInfo接口");
        String signSource = GameId + param[0] + param[1] + param[2] + param[3] + param[4] + param[5] + AppKey;// 组装签名原文
        String sign = MD5.md5Digest(signSource).toUpperCase();
        LOG.error("[签名原文]" + signSource);
        LOG.error("[签名结果]" + sign);

        String url = serverUrl + "?GameID=" + GameId + "&SourceID=" + param[0] + "&DeviceID=" + param[1] + "&DeviceNo=" + param[2] + "&UserID=" + param[3]
                + "&UserName=" + param[4] + "&QQ=" + "&Mobile=" + "&EMail=" + "&Token=" + param[5] + "&Sign=" + sign;
        LOG.error("[请求url]" + url);

        String result = HttpUtils.sendGet(url, new HashMap<String, String>());
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串
        if (result == null) {
            LOG.error("chYh 登陆失败:result is null");
            return null;
        }

        //
        try {
            String[] rs = result.split("\\|");
            if ("1".equals(rs[0])) {// 成功
                LOG.error("chYh 登陆成功");
                return result;
            } else {
                LOG.error("chYh 登陆失败:" + rs[1]);
                return null;
            }
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("chYh 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }

    }
}
