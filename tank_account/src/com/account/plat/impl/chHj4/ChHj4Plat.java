package com.account.plat.impl.chHj4;

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

//class UcAccount {
//	public int ucid;
//	public String nickName;
//}

@Component
public class ChHj4Plat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static String GameId;

    private static String AppKey;

    private static String API_KEY;

    // 分配给游戏合作商的接入密钥,请做好安全保密
    // private static String SecretKey = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chHj4/", "plat.properties");
        GameId = properties.getProperty("GameId");
        AppKey = properties.getProperty("AppKey");
        // SecretKey = properties.getProperty("SecretKey");
        serverUrl = properties.getProperty("VERIRY_URL");
        API_KEY = properties.getProperty("API_KEY");
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

        if (vParam.length >= 7 && (vParam[6].equals("uc") || vParam[6].equals("360"))) {
            String[] rs = backStr.split("\\|");
            if (rs.length < 3) {
                return GameError.SDK_LOGIN;
            }
            userId = rs[2];
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
        try {

            LOG.error("pay chHj4");
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
                LOG.error("chHj4 充值发货失败！！ " + code);
                return "0|" + (System.currentTimeMillis() / 1000);
            }
            return "1|" + (System.currentTimeMillis() / 1000);
        } catch (Exception e) {
            LOG.error("chHj4 充值异常:" + e.getMessage());
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
        LOG.error("caohuaHj4 开始调用sidInfo接口");
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
            return null;
        }
        //
        try {
            String[] rs = result.split("\\|");
            if ("1".equals(rs[0])) {// 成功
                LOG.error("caohuaHj4 登陆成功");
                return result;
            } else {
                LOG.error("caohuaHj4 登陆失败:" + rs[1]);
                return null;
            }
        } catch (Exception e) {
            LOG.error("caohuaHj4 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }

    }


    @Override
    public String order(WebRequest request, String content) {
        LOG.error("order chHj4");
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

    public static void main(String[] args) {
	     /*  LOG.error("caohuaHj4 开始调用sidInfo接口");
	        String url = "http://token.api.cp.caohua.com/Api/CheckToken.ashx?" + 
	        "GameID=11&SourceID=1039&DeviceID=4441829&DeviceNo=B194C44515F5F565C86811F9219C331B&UserName=MI5s**r&UserID=a5a1be1e9ffc670a&QQ=&Mobile=&EMail=&Token=a5a1be1e9ffc670a_a5a1be1e9ffc670a_3e7ab2fb0f35f1fb6baa0847f5da229d&Sign=02F814C4EF985C2B32DCC56D8AA22FFB";
	        LOG.error("[请求url]" + url);

	        String result = HttpUtils.sendGet(url, new HashMap<String, String>());
	        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串*/
    }
}
