package com.account.plat.impl.haima;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
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
public class HaimaPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    private static String AppID;
    private static String AppKey;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/haima/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
        serverUrl = properties.getProperty("VERIRY_URL");
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

        String access_token = vParam[0];
        String uid = vParam[1];
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
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay haima android");
        LOG.error("[接收到的参数]" + content);
        try {
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + request.getParameter(paramName));
            }

            String notify_time = request.getParameter("notify_time");
            String appid = request.getParameter("appid");
            String out_trade_no = request.getParameter("out_trade_no");
            String total_fee = request.getParameter("total_fee");
            String subject = request.getParameter("subject");
            String body = request.getParameter("body");
            String trade_status = request.getParameter("trade_status");
            String user_param = request.getParameter("user_param");
            String sign = request.getParameter("sign");

            notify_time = URLEncoder.encode(notify_time, "UTF-8");
            subject = URLEncoder.encode(subject, "UTF-8");
            body = URLEncoder.encode(body, "UTF-8");// Android

            if (!"1".equals(trade_status)) {
                LOG.error("result failed");
                return "success";
            }
            String signSource = "notify_time=" + notify_time + "&appid=" + appid + "&out_trade_no=" + out_trade_no + "&total_fee=" + total_fee + "&subject="
                    + subject + "&body=" + body + "&trade_status=" + trade_status + AppKey;
            String orginSign = MD5.md5Digest(signSource).toLowerCase();

            LOG.error("签名原文：" + signSource);
            LOG.error("签名：" + orginSign + " | " + sign);
            if (!orginSign.equals(sign)) {
                LOG.error("验签失败");
                return "failure";
            }
            String[] infos = user_param.split("_");
            if (infos.length != 4) {
                LOG.error("haima 参数不正确");
                return "failure";
            }

            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);
            String user_id = infos[3];

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = user_id;
            payInfo.orderId = out_trade_no;

            payInfo.serialId = user_param;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(total_fee);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code == 0) {
                LOG.error("返回充值成功");
            } else {
                LOG.error("返回充值失败");
            }
            return "success";
        } catch (Exception e) {
            LOG.error("充值异常:" + e.getMessage());
            e.printStackTrace();
            return "failure";
        }
    }

    private boolean verifyAccount(String uid, String token) {
        LOG.error("haima 开始调用sidInfo接口");
        JSONObject json = new JSONObject();
        json.put("appid", AppID);
        json.put("t", token);
        LOG.error("登陆验证 " + serverUrl + "" + json.toString());
        Map<String, String> paramsMap = new HashMap<String, String>();
        paramsMap.put("appid", AppID);
        paramsMap.put("t", token);
        String postBody = "appid=" + AppID + "&t=" + token;
        String result;
        try {
            result = HttpUtils.sentPost(serverUrl, postBody);
            if (result == null) {
                return false;
            }
            LOG.error("[响应结果]" + result);
            LOG.error("调用sidInfo接口结束");
            if ("success".equals(result.toLowerCase().trim())) {
                LOG.error("haima 登陆成功:");
                return true;
            } else {
                LOG.error("haima 登陆失败:" + result + " |token" + token);
                return false;
            }
        } catch (Exception e) {
            LOG.error("用户验证异常:" + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}
