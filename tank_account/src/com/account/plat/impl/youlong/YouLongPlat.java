package com.account.plat.impl.youlong;

import java.net.URLDecoder;
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
public class YouLongPlat extends PlatBase {


    private static String AppId;
    private static String AppKey;
    private static String VERIRY_URL;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/youlong/", "plat.properties");
        AppId = properties.getProperty("AppId");
        AppKey = properties.getProperty("AppKey");
        VERIRY_URL = properties.getProperty("VERIRY_URL");
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
        if (vParam.length < 1) {
            return GameError.PARAM_ERROR;
        }
        String uid = verifyAccount(vParam[0]);

        if (uid == null) {
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
            response.setUserInfo("1");
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

    private String verifyAccount(String token) {
        LOG.error("youlong 开始调用sidInfo接口");
        String body = "token=" + token + "&pid=" + AppId;
        LOG.error("[请求参数]" + body);
        String result = HttpUtils.sentPost(VERIRY_URL, body);
        LOG.error("[响应结果]" + result);
        try {
            if (result != null) {
                JSONObject rsp = JSONObject.fromObject(result);
                String state = rsp.getString("state");
                if (state.equals("1")) {
                    return rsp.getString("username");
                }
            }
            return null;
        } catch (Exception e) {
            LOG.error("接口返回异常");
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        Iterator<String> iterator = request.getParameterNames();
        LOG.error("pay youlong");
        LOG.error("pay youlong content:" + content);
        Map<String, String> params = new HashMap<String, String>();
        try {
            LOG.error("[参数开始]");
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
                params.put(paramName, URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
            }
            LOG.error("[参数结束]");


            String orderId = request.getParameter("orderId");
            String userName = request.getParameter("userName");
            String amount = request.getParameter("amount");
            String extra = request.getParameter("extra");
            String flag = request.getParameter("flag");


            //MD5(orderId+userName+amount+extra+PKEY)

            String signStr = orderId + userName + amount + extra + AppKey;
            LOG.error("代签名字符串:" + signStr);
            String checkSign = MD5.md5Digest(signStr).toUpperCase();

            if (!checkSign.equals(flag)) {
                LOG.error("youlong 签名验证失败, checkSign:" + checkSign);
                return "FAIL";
            }

            String[] v = extra.split("_");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = userName;
            payInfo.orderId = orderId;
            payInfo.serialId = extra;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);

            payInfo.realAmount = Double.valueOf(amount);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                if (code == 1) {
                    LOG.error("youlong 重复的订单！！ " + code);
                    return "OK";
                }
                LOG.error("youlong 充值发货失败！！ " + code);
                return "FAIL";
            } else {
                LOG.error("youlong 充值发货成功！！ " + code);
                return "OK";
            }
        } catch (Exception e) {
            LOG.error("youlong 充值异常！！:" + e.getMessage());
            e.printStackTrace();
            return "FAIL";
        }
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
        return null;
    }

}
