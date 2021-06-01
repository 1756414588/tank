package com.account.plat.impl.chYhGp;

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
public class ChYhGpPlat extends PlatBase {

    private static String serverUrl = "";

    private static String AppID;

    private static String AppKey;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chYhGp/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
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

        String[] vParam = sid.split("__");
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[0];
        if (!verifyAccount(vParam[0], vParam[1])) {
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

        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }

    private static String getParamsStr(HashMap<String, String> params) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;
        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (params.get(k) == null || params.get(k).equals("")) {
                continue;
            }
            v = (String) params.get(k);

            if (i != 0) {
                str += "&";
            }
            str += k + "=" + v;
        }
        return str;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay chYhGp");
        try {
            LOG.error("pay chYhGp content:" + content);
            LOG.error("[开始参数]");
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
            }
            LOG.error("[结束参数]");

            String trade_no = request.getParameter("trade_no");
            String serialNumber = request.getParameter("serialNumber");
            String money = request.getParameter("money");
            String status = request.getParameter("status");
            String t = request.getParameter("t");
            String sign = request.getParameter("sign");
            String reserved = request.getParameter("reserved");
            String game_uin = request.getParameter("game_uin");

            // sign=md5(serialNumber+money+status+t+SERVER_KEY)

            String signStr = serialNumber + money + status + t + AppKey;
            LOG.error("[签名原文]" + signStr);
            String signCheck = MD5.md5Digest(signStr);
            LOG.error("[签名结果]" + signCheck);

            if (!sign.equals(signCheck)) {  // 签名失败
                LOG.error("chYhGp sign error");
                return "success";
            }

            if (!status.equals("1")) {  // 支付状态不正确
                LOG.error("chYhGp error status:" + status);
                return "success";
            }

            String[] v = reserved.split("__");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = game_uin;
            payInfo.orderId = trade_no;

            payInfo.serialId = reserved;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);

            if (code == 0) {
                LOG.error("chYhGp 充值发货成功 ");
            } else if (code == 1) {
                LOG.error("chYhGp 重复的订单号！！ " + code);
            } else {
                LOG.error("chYhGp 充值发货失败！！ " + code);
            }
            return "success";
        } catch (Exception e) {
            LOG.error("chYhGp 充值异常:" + e.getMessage());
            e.printStackTrace();
            return "success";
        }
    }

    private boolean verifyAccount(String game_uin, String token) {
        LOG.error("chYhGp 开始调用sidInfo接口");
        // sign=md5(game_uin+appid+t+SERVER_KEY)
        long t = System.currentTimeMillis() / 1000;
        String signStr = game_uin + AppID + t + AppKey;
        LOG.error("待签名字符串:" + signStr);
        String sign = MD5.md5Digest(signStr);
        LOG.error("签名:" + sign);
        HashMap<String, String> params = new HashMap<>();
        params.put("game_uin", game_uin);
        params.put("appid", AppID);
        params.put("token", token);
        params.put("t", String.valueOf(t));
        params.put("sign", sign);
        String url = serverUrl + getParamsStr(params);
        LOG.error("请求url:" + url);
        try {
            String result = HttpUtils.sendGet(url, new HashMap<String, String>());
            LOG.error("[响应结果]" + result);
            if (result.equals("true")) {
                return true;
            }
            return false;
        } catch (Exception e) {
            LOG.error("chYhGp 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }
    }
}
