package com.account.plat.impl.qmyxzs;

import java.util.Date;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSON;
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
public class QmyxzsPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static String APP_ID;

    private static String APP_KEY = "";

    private static String MD5_KEY = "";

    // private static String PAY_KEY = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/zhuoyou/", "plat.properties");
        APP_ID = properties.getProperty("APP_ID");
        APP_KEY = properties.getProperty("APP_KEY");
        MD5_KEY = properties.getProperty("MD5_KEY");
        serverUrl = properties.getProperty("VERIRY_URL");
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
        if (vParam.length < 1) {
            return GameError.PARAM_ERROR;
        }

        String sid1 = vParam[0];
        String access_token = vParam[1];
        JSONObject user = verifyAccount(sid1, access_token);
        if (user == null) {
            return GameError.SDK_LOGIN;
        }

        String userId = user.getString("user_id");

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

        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay qmyxzs");
        JSONObject rets = new JSONObject();
        JSONObject state = new JSONObject();
        rets.put("state", state);
        try {
            LOG.error("[接到参数]" + content);

            String payRet = request.getParameter("payRet");
            String gameInfo = request.getParameter("gameInfo");
            String extData = request.getParameter("extData");

            JSONObject payCall = JSONObject.fromObject(payRet);

            String accountId = payCall.getString("accountId");
            String qmOrderId = payCall.getString("qmOrderId");
            String billId = payCall.getString("billId");
            String amount = payCall.getString("amount");
            String callbackInfo = payCall.getString("callbackInfo");
            int successFlag = payCall.getInt("successFlag");
            String payTime = payCall.getString("payTime");
            String payFee = payCall.getString("payFee");
            String gameData01 = payCall.getString("gameData01");

            if (successFlag != 200) {
                state.put("code", 0);
                state.put("msg", "支付未完成");
                return rets.toString();
            }

            boolean verify_result = verifyPay("", qmOrderId);
            if (!verify_result) {
                state.put("code", 1);
                state.put("msg", "query qmorderId fail");
                return rets.toString();
            }
            String[] infos = gameData01.split("_");
            if (infos.length != 3) {
                state.put("code", 2);
                state.put("msg", "传输参数gameData01 error");
                return rets.toString();
            }

            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = accountId;
            payInfo.orderId = qmOrderId;

            payInfo.serialId = gameData01;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(amount) / 100.0;
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code == 0) {
                state.put("code", 2000);
                state.put("msg", "pay ok");
                LOG.error("充值发货成功");
                return rets.toString();
            } else {
                state.put("code", 2000);
                state.put("msg", "pay ok,Repeat qmorderId");
                LOG.error("充值发货失败");
                return rets.toString();
            }
        } catch (Exception e) {
            state.put("code", 3);
            state.put("msg", "cp server exception");
            return rets.toString();
        }
    }

    private JSONObject verifyAccount(String sid, String access_token) {
        LOG.error("qmyxzs 开始调用sidInfo接口");

        JSONObject param = new JSONObject();
        param.put("actionid", "chksession");

        JSONObject data = new JSONObject();
        data.put("sid", sid);
        param.put("data", data);

        JSONObject gameInfo = new JSONObject();
        gameInfo.put("gameId", APP_ID);
        param.put("gameInfo", gameInfo);

        LOG.error("[请求参数]" + param.toString());
        LOG.error("[请求地址]" + serverUrl);

        String result = HttpUtils.sentPost(serverUrl, param.toString());
        LOG.error("[响应结果]" + result);

        try {
            JSONObject rsp = JSONObject.fromObject(result);

            if (rsp == null || !rsp.containsKey("data") || !rsp.containsKey("state")) {
                LOG.error("qmyxzs 登陆失败未取到结果");
                return null;
            }

            JSONObject state = rsp.getJSONObject("state");
            int code = state.getInt("code");
            if (code == 2000) {
                JSONObject retData = rsp.getJSONObject("data");
                return retData;
            }
            LOG.error("登录失败" + state.getString("msg"));
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常");
            e.printStackTrace();
            return null;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }
        return null;
    }

    private boolean verifyPay(String sid, String qmOrderId) {
        LOG.error("qmyxzs 开始查询pay接口");

        JSONObject param = new JSONObject();

        JSONObject data = new JSONObject();
        data.put("sid", "");
        data.put("qmOrderId", qmOrderId);
        param.put("data", data);

        JSONObject gameInfo = new JSONObject();
        gameInfo.put("gameId", APP_ID);
        param.put("gameInfo", gameInfo);

        LOG.error("[请求参数]" + param.toString());
        LOG.error("[请求地址]" + serverUrl);

        String result = HttpUtils.sentPost(serverUrl, param.toString());
        LOG.error("[响应结果]" + result);

        try {
            JSONObject rsp = JSONObject.fromObject(result);

            if (rsp == null || !rsp.containsKey("payRet") || !rsp.containsKey("state")) {
                LOG.error("qmyxzs 查询充值失败未取到结果");
                return false;
            }

            JSONObject state = rsp.getJSONObject("state");
            int code = state.getInt("code");
            if (code == 2000) {
                JSONObject retData = rsp.getJSONObject("data");
                // 支付
                return true;
            }
            LOG.error("查询订单失败");
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("查询订单接口返回异常");
            e.printStackTrace();
            return false;
        }
        return false;
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return null;
    }

}
