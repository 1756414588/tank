package com.account.plat.impl.sina;

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
import com.account.plat.impl.self.util.CpTransSyncSignValid;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class SinaPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static String APP_ID;

    private static String APP_KEY = "";


    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/sina/", "plat.properties");
        APP_ID = properties.getProperty("APP_ID");
        APP_KEY = properties.getProperty("APP_KEY");
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

        String ticket = vParam[0];
        String login_id = vParam[1];
        String login_key = vParam[2];
        JSONObject user = verifyAccount(ticket, login_id, login_key);
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
        LOG.error("pay yyh");
        LOG.error("[开始接收参数]");
        Iterator<String> it = request.getParameterNames();
        while (it.hasNext()) {
            String paramKey = it.next();
            String paramValue = request.getParameter(paramKey);
            LOG.error(paramKey + "=" + paramValue);
        }
        LOG.error("[结束接收参数]");
        try {

            String transdata = request.getParameter("transdata").trim();
            String sign = request.getParameter("sign").trim();

            JSONObject params = JSONObject.fromObject(transdata);

            String exorderno = params.getString("exorderno");
            String transid = params.getString("transid");
            String appid = params.getString("appid");
            String waresid = params.getString("waresid");
            String feetype = params.getString("feetype");
            String money = params.getString("money");
            String count = params.getString("count");
            String result = params.getString("result");
            String transtype = params.getString("transtype");
            String transtime = params.getString("transtime");
            String cpprivate = params.getString("cpprivate");

            if (!"0".equals(result)) {
                LOG.error("订单支付失败");
                return "failure";
            }

            boolean valid_result = CpTransSyncSignValid.validSign(transdata, sign, APP_KEY);
            if (!valid_result) {
                LOG.error("验签失败");
                return "failure";
            }

            String[] infos = cpprivate.split("_");
            if (infos.length != 4) {
                LOG.error("传参不正确");
                return "failure";
            }

            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);
            String user_id = infos[3];

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = user_id;
            payInfo.orderId = transid;

            payInfo.serialId = cpprivate;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(money) / 100.0;
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int retcode = payToGameServer(payInfo);
            if (retcode == 0) {
                LOG.error("发货失败");
                return "success";
            } else {
                LOG.error("发货失败");
                return "failure";
            }
        } catch (Exception e) {
            LOG.error("支付异常");
            return "failure";
        }
    }

    private JSONObject verifyAccount(String ticket, String login_id, String login_key) {
        LOG.error("yyh 开始调用sidInfo接口");

        String body = "ticket=" + ticket + "&login_id=" + login_id + "&login_key=" + login_key;

        LOG.error("[请求参数]" + body);
        LOG.error("[请求地址]" + serverUrl);

        String result = HttpUtils.sentPost(serverUrl, body);
        LOG.error("[响应结果]" + result);

        try {
            JSONObject rsp = JSONObject.fromObject(result);
            if (rsp == null || !rsp.containsKey("status") || !rsp.containsKey("data")) {
                LOG.error("登陆失败未取到结果");
                return null;
            }
            String code = rsp.getString("status");
            if ("0".equals(code.trim())) {
                return rsp.getJSONObject("data");
            }
            LOG.error("登陆失败" + code + "|" + rsp.getString("message"));
            return null;

        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常");
            e.printStackTrace();
            return null;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return null;
    }

}
