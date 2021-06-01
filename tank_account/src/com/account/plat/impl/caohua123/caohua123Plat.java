package com.account.plat.impl.caohua123;

import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
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
import com.account.plat.impl.self.util.CpTransSyncSignValid;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

class LenovoAccount {
    public String DeviceID;
    public String AccountID;
    public String Username;
}

@Component
public class caohua123Plat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    private static String APPKEY = "";

    private static String APP_ID = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/caohua123/", "plat.properties");
        APPKEY = properties.getProperty("APPKEY");
        serverUrl = properties.getProperty("VERIRY_URL");
        APP_ID = properties.getProperty("APP_ID");
    }

    @Override
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

        String userid = vParam[0];
        String token = vParam[1];

        boolean b = verifyAccount(userid, token);
        if (b == false) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userid);
        if (account == null) {
            token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(userid);
            account.setAccount(getPlatNo() + "_" + userid);
            account.setPasswd(userid);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setToken(token);
            account.setDeviceNo(deviceNo);

            Date now = new Date();
            account.setLoginDate(now);
            account.setCreateDate(now);
            accountDao.insertWithAccount(account);
        } else {
            token = RandomHelper.generateToken();
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
        return GameError.SDK_LOGIN;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay caohua123");

        String transdata = request.getParameter("transdata");
        String sign = request.getParameter("sign");

        try {
            LOG.error("[接收到的参数]" + "transdata:" + transdata + "|" + "sign:" + sign);
            JSONObject requestParam = JSONObject.fromObject(transdata);
            String transid = requestParam.getString("transid");
            if (!CpTransSyncSignValid.validSign(transdata.toString(), sign, APPKEY)) {
                LOG.error("签名不一致");
                return "FAILURE";
            }

            Integer result = requestParam.getInt("result");
            String cpprivate = requestParam.getString("cpprivate");
            Integer money = requestParam.getInt("money");
            if (result == null || result != 0) {
                LOG.error("支付结果失败");
                return "SUCCESS";
            }

            String[] infos = cpprivate.split("_");
            if (infos.length != 3) {
                LOG.error("自有参数有问题");
                return "SUCCESS";
            }

            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = String.valueOf(lordId);
            payInfo.orderId = transid;

            payInfo.serialId = cpprivate;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(money) / 100;
            payInfo.amount = (int) payInfo.realAmount;
            int code = payToGameServer(payInfo);
            if (code == 0) {
                LOG.error("caohua123 返回充值成功");
            } else {
                LOG.error("caohua123 返回充值失败");
            }
            return "SUCCESS";
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "SUCCESS";
    }

    private boolean verifyAccount(String userid, String token) {
        LOG.error("caohua123 开始调用sidInfo接口");
        try {
            HashMap<String, String> params = new HashMap<String, String>();
            long times = System.currentTimeMillis() / 1000;
            params.put("appid", APP_ID);
            params.put("userid", userid);
            params.put("times", times + "");
            params.put("token", token);

            String str = getParamsStr(params).toString() + APPKEY;
            String sign = MD5.md5Digest(str).toUpperCase();
            String paramsSrt = str + "&sign=" + sign;
            LOG.error("登陆请求参数=" + paramsSrt);
            String result = HttpUtils.sentPost(serverUrl, paramsSrt);
            LOG.error("登陆接受到的参数=" + result);

            JSONObject jb = JSONObject.fromObject(result);
            String code = jb.getString("code");
            if (!"200".equals(code)) {
                LOG.error("验证失败");
                return false;
            }
            LOG.error("验证成功");
            return true;
        } catch (Exception e) {
            LOG.error("接口返回异常");
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }
    }

    private JSONObject getParamsStr(Map<String, String> params) {
        JSONObject json = new JSONObject();
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("sign") || k.equals("plat")) {
                continue;
            }

            if (params.get(k) == null || params.get(k).equals("")) {
                continue;
            }

            json.put(k, (String) params.get(k));
        }
        return json;
    }

}
