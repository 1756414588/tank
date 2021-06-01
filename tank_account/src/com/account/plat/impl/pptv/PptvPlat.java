package com.account.plat.impl.pptv;

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
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class PptvPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    // private static String APP_ID;

    // private static String APP_KEY = "";

    private static String PAY_KEY = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/pptv/", "plat.properties");
        // if (properties != null) {
        // APP_ID = properties.getProperty("APP_ID");
        // APP_KEY = properties.getProperty("APP_KEY");
        PAY_KEY = properties.getProperty("PAY_KEY");
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

        String[] vParam = sid.split(",");
        if (vParam.length < 3) {
            return GameError.PARAM_ERROR;
        }

        String sessionId = vParam[0];
        String userId = vParam[1];
        String username = vParam[2];
        if (!verifyAccount(username, sessionId)) {
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

        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay pptv");
        JSONObject json = new JSONObject();
        try {
            LOG.error("[接收参数]" + content);

            String sid = request.getParameter("sid");
            String roid = request.getParameter("roid");
            String username = request.getParameter("username");
            String oid = request.getParameter("oid");
            String amount = request.getParameter("amount");
            String extra = request.getParameter("extra");
            String time = request.getParameter("time");
            String sign = request.getParameter("sign");
            String code = request.getParameter("code");
            String message = request.getParameter("message");

            StringBuffer sb = new StringBuffer();
            sb.append("sid=").append(sid).append("&");
            sb.append("roid=").append(roid).append("&");
            sb.append("username=").append(username).append("&");
            sb.append("oid=").append(oid).append("&");
            sb.append("amount=").append(amount).append("&");
            sb.append("extra=").append(extra).append("&");
            sb.append("time=").append(time).append("&");
            sb.append("sign=").append(sign).append("&");
            sb.append("code=").append(code).append("&");
            sb.append("message=").append(message);
            LOG.error("[接收到参数]" + sb.toString());

            // if (!"1".equals(code)) {
            // LOG.error("扣费不成功");
            // return "success";
            // }

            // order=xxxx&money=xxxx&mid=xxxx&time=xxxx&result=x&ext=xxx&key=xxxx
            String signSource = sid + username + roid + oid + amount + time + PAY_KEY;
            String orginSign = MD5.md5Digest(signSource);
            LOG.error("[签名原文]" + signSource);
            LOG.error("[签名结果]" + orginSign + " | " + sign);
            if (!orginSign.equals(sign)) {
                json.put("code", 4);
                json.put("message", "验证失败");
                LOG.error("验签失败");
                return json.toString();
            }
            String[] infos = extra.split("_");
            if (infos.length != 4) {
                json.put("code", 2);
                json.put("message", "参数不正确");
                LOG.error("参数不正确");
                return json.toString();
            }
            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);
            String userId = infos[3];

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = userId;
            payInfo.orderId = oid;

            payInfo.serialId = extra;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(amount);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int retcode = payToGameServer(payInfo);
            if (retcode == 0) {
                LOG.error("返回充值成功");
                json.put("code", 1);
                json.put("message", "支付成功");
            } else if (retcode == 1) {
                json.put("code", 3);
                json.put("message", "订单已存在");
                LOG.error("订单已存在");
            } else {
                LOG.error("返回充值成功");
                json.put("code", 1);
                json.put("message", "支付成功");
            }
            return json.toString();
        } catch (Exception e) {
            json.put("code", 2);
            json.put("message", "支付异常");
            LOG.error("返回充值失败");
            return json.toString();
        }
    }

    private boolean verifyAccount(String username, String sessionid) {
        LOG.error("pptv 开始调用sidInfo接口");

        Map<String, String> parameter = new HashMap<>();
        parameter.put("type", "login");
        parameter.put("sessionid", sessionid);
        parameter.put("username", username);
        parameter.put("app", "mobgame");
        LOG.error("[请求参数]" + parameter.toString());
        LOG.error("[请求地址]" + serverUrl);

        String result = HttpUtils.sendGet(serverUrl, parameter);
        LOG.error("[响应结果]" + result);

        try {
            JSONObject rsp = JSONObject.fromObject(result);
            int msg_code = rsp.getInt("status");
            String msg_desc = rsp.getString("message");
            // int interval = rsp.getInt("interval");
            // int times = rsp.getInt("times");
            // boolean roll = rsp.getBoolean("roll");

            if (msg_code == 1) {
                return true;
            }

            LOG.error("pptv 登陆失败:" + msg_desc);
            return false;

        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常");
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
