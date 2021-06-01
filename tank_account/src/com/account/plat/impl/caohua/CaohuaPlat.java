package com.account.plat.impl.caohua;

import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
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

//class UcAccount {
//	public int ucid;
//	public String nickName;
//}

@Component
public class CaohuaPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static String GameId;

    private static String AppKey;

    private static String SecretKey;

    private static String HwAppID;

    private static String HwAppKEY;

    private static String HwServerKEY;

    // 分配给游戏合作商的接入密钥,请做好安全保密
    // private static String SecretKey = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/caohua/", "plat.properties");
        GameId = properties.getProperty("GameId");
        AppKey = properties.getProperty("AppKey");
        SecretKey = properties.getProperty("SecretKey");
        serverUrl = properties.getProperty("VERIRY_URL");
        HwAppID = properties.getProperty("HwAppID");
        HwAppKEY = properties.getProperty("HwAppKEY");
        HwServerKEY = properties.getProperty("HwServerKEY");
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
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay ch");
        LOG.error("[开始参数]");
        try {
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
                LOG.error("ch sign error");
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
                LOG.error("ch 充值发货失败！！ " + code);
                return "0|" + (System.currentTimeMillis() / 1000);
            }
            return "1|" + (System.currentTimeMillis() / 1000);
        } catch (Exception e) {
            LOG.error("ch 充值异常:" + e.getMessage());
            e.printStackTrace();
            return "0|" + (System.currentTimeMillis() / 1000);
        }
    }

    @Override
    public String newPayBack(WebRequest request, String content,
                             HttpServletResponse response, String type) {
        if (type.equals("new")) { // 新支付
            return newPayBack(request, content, response);
        } else if (type.equals("hw")) { // 华为支付
            return hwPayBack(request, content, response);
        }
        return null;
    }

    public String hwPayBack(WebRequest request, String content,
                            HttpServletResponse response) {
        LOG.error("pay caohua");
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

            String signSource = OrderNo + OutPayNo + UserID + ServerNo + PayType + Money + PMoney + PayTime + HwServerKEY;// 组装签名原文
            String sign = MD5.md5Digest(signSource).toUpperCase();
            LOG.error("[签名原文]" + signSource);
            LOG.error("[签名结果]" + sign);

            if (!sign.equals(Sign)) {
                LOG.error("caohua sign error");
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
                LOG.error("caohua 充值发货失败！！ " + code);
                return "0";
            }
            return "1";
        } catch (Exception e) {
            LOG.error("caohua 充值异常:" + e.getMessage());
            e.printStackTrace();
            return "1";
        }
    }

    public String newPayBack(WebRequest request, String content,
                             HttpServletResponse response) {
        LOG.error("pay ch v2.5");
        LOG.error("pay ch v2.5 content:" + content);
        LOG.error("[开始参数]");
        try {
            Map<String, String> params = new HashMap<String, String>();
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + request.getParameter(paramName));
                params.put(paramName, URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
            }
            LOG.error("[结束参数]");
//			String[] kvs = content.split("&");
//			for (String kv : kvs) {
//				String[] k2v = kv.split("=");
//				params.put(k2v[0], URLDecoder.decode(k2v[1], "UTF-8"));
//			}
            // 排序key值
            List<String> keys = new ArrayList<String>(params.keySet());
            Collections.sort(keys);
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < keys.size(); i++) {
                String k = keys.get(i);
                String v = params.get(k);
                if (!k.equalsIgnoreCase("sign") && !k.equalsIgnoreCase("plat")) {
                    sb.append(k + "=" + v + "&");
                }
            }
            sb.deleteCharAt(sb.length() - 1);
            String signstr = sb.toString();
            signstr = signstr + SecretKey;
            signstr = URLDecoder.decode(signstr, "UTF-8");
            String checkSign = MD5.md5Digest(signstr).toUpperCase();
            String sign = params.get("sign");

            LOG.error("signstr:" + signstr);
            LOG.error("checkSign:" + checkSign);
            LOG.error("sign:" + sign);

            if (!sign.equalsIgnoreCase(checkSign)) {
                LOG.error("签名验证失败");
                return returnCode(202);
            }

            String info = params.get("extra");
            String[] v = info.split("_");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = params.get("userid");
            payInfo.orderId = params.get("orderno");

            payInfo.serialId = info;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(params.get("pay_amt")) / 100.0;
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                if (code == 2) {
                    return returnCode(203);
                }
                LOG.error("ch v2.5 充值发货失败！！ " + code);
            } else {
                LOG.error("ch v2.5 充值发货成功！！ " + code);
            }
            return returnCode(200);
        } catch (Exception e) {
            LOG.error("ch v2.5 充值异常:" + e.getMessage());
            e.printStackTrace();
            return returnCode(203);
        }
    }

    private String returnCode(int code) {
        JSONObject json = new JSONObject();
        json.put("code", code);
        switch (code) {
            case 200:
                json.put("msg", "成功");
                json.put("data", "");
                break;
            case 202:
                json.put("msg", "签名校验失败");
                json.put("data", "");
                break;
            case 203:
                json.put("msg", "其他错误");
                json.put("data", "");
                break;
            default:
                break;
        }
        return json.toString();
    }

    private String verifyAccount(String[] param) {
        LOG.error("caohua 开始调用sidInfo接口");
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
            LOG.error("caohua 登陆失败:result is null");
            return null;
        }
        //
        try {
            String[] rs = result.split("\\|");
            if ("1".equals(rs[0])) {// 成功
                LOG.error("ch 登陆成功");
                return result;
            } else {
                LOG.error("ch 登陆失败:" + rs[1]);
                return null;
            }
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("ch 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }
    }

}
