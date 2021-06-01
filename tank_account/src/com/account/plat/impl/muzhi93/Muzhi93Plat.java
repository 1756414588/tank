package com.account.plat.impl.muzhi93;

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

//class UcAccount {
//	public int ucid;
//	public String nickName;
//}

@Component
public class Muzhi93Plat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    private static String AppID;
    private static String AppKey;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties(
                "com/account/plat/impl/muzhi93/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
        serverUrl = properties.getProperty("VERIRY_URL");
    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion()
                || !req.hasDeviceNo()) {
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

        String uid = vParam[0];
        String access_token = vParam[1];
        if (!verifyAccount(uid, access_token)) {
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
    public GameError doLogin(JSONObject param, JSONObject response) {
        return null;
    }

    @Override
    public String payBack(WebRequest request, String content,
                          HttpServletResponse response) {
        LOG.error("pay duwan android");
        LOG.error("[接收到的参数]" + content);
        Iterator<String> iterator = request.getParameterNames();
        while (iterator.hasNext()) {
            String key = iterator.next();
            String value = request.getParameter(key);
            LOG.error(key + ":" + value);
        }

        try {
            String order = request.getParameter("order");
            String time = request.getParameter("time");
            String money = request.getParameter("money");
            String account_id = request.getParameter("account_id");
            String cporder = request.getParameter("cporder");
            String sign = request.getParameter("sign");

            String signSource = account_id + cporder + order + AppKey + time
                    + money;
            String orginSign = MD5.md5Digest(signSource).toLowerCase();

            LOG.error("[签名原文]：" + signSource);
            LOG.error("[签名結果]：" + orginSign + " | " + sign);
            if (!orginSign.equals(sign)) {
                LOG.error("验签失败");
                return "4";
            }
            String[] infos = cporder.split("_");
            if (infos.length != 3) {
                LOG.error("haima 参数不正确");
                return "0";
            }

            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = account_id;
            payInfo.orderId = order;

            payInfo.serialId = cporder;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code == 0) {
                LOG.error("返回充值成功");
            } else {
                LOG.error("返回充值失败");
            }
            return "1";
        } catch (Exception e) {
            e.printStackTrace();
            return "2";
        }
    }

    private boolean verifyAccount(String accountId, String token) {
        LOG.error("duwan 开始调用sidInfo接口");
        long time = (System.currentTimeMillis() / 1000);
        Map<String, String> paramsMap = new HashMap<String, String>();
        paramsMap.put("account_id", accountId);
        paramsMap.put("app_id", AppID);
        paramsMap.put("token", token);
        paramsMap.put("time", String.valueOf(time));
        String signNation = accountId + token + time + AppKey;
        String sign = MD5.md5Digest(signNation).toLowerCase();

        LOG.error("[簽名原文]" + signNation);
        LOG.error("[簽名結果]" + sign);
        paramsMap.put("sign", sign);

        LOG.error("登陆验证 " + serverUrl + "" + paramsMap.toString());
        try {
            String result = HttpUtils.sendGet(serverUrl, paramsMap);
            LOG.error("[登錄結果]" + result);
            if (result == null) {
                return false;
            }
            int code = Integer.valueOf(result);
            if (code > 0) {
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

	/*public static void main(String[] args) {
		LOG.error("duwan 开始调用sidInfo接口");
		long time = (System.currentTimeMillis() / 1000);

		String accountId = "663893";
		String token = "3b405fa1f593c78c71cebc9ffc82b344";
		String AppID = "1606131003";
		String AppKey = "3d108eaf2fca22e0713ecc232d7bccad";
		String serverUrl ="http://h.m.93pk.com/action.php?module=check_token";

		Map<String, String> paramsMap = new HashMap<String, String>();
		paramsMap.put("account_id", accountId);
		paramsMap.put("app_id", AppID);
		paramsMap.put("token", token);
		paramsMap.put("time", String.valueOf(time));
		String signNation = accountId + token + time + AppKey;
		String sign = MD5.md5Digest(signNation).toLowerCase();

		LOG.error("[簽名原文]" + signNation);
		LOG.error("[簽名結果]" + sign);
		paramsMap.put("sign", sign);

		LOG.error("登陆验证 " + serverUrl + "" + paramsMap.toString());
		String result = HttpUtils.sendGet(serverUrl, paramsMap);
		LOG.error("[登錄結果]" + result);
	}*/
}
