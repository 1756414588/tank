package com.account.plat.impl.chdgfbAppstore;

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
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

//class UcAccount {
//	public int ucid;
//	public String nickName;
//}

@Component
public class ChdgfbAppstorePlat extends PlatBase {
    // sdk server的接口地址

    private static String PUBLIC_KEY = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chdgfbAppstore/", "plat.properties");
        PUBLIC_KEY = properties.getProperty("PUBLIC_KEY");
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
        if (vParam.length < 3) {
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[0];
        // String userName = vParam[1];
        // String token = vParam[2];

        if (!verifyAccount(vParam)) {
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

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay chdgfb_appstore");
        LOG.error("pay chdgfb_appstore content: " + content);
        try {
            LOG.error("[开始接收参数]");
            Map<String, String> params = new HashMap<String, String>();
            Iterator<String> it = request.getParameterNames();
            while (it.hasNext()) {
                String paramKey = it.next();
                String paramValue = request.getParameter(paramKey);
                LOG.error(paramKey + "=" + paramValue);
                params.put(paramKey, paramValue);
            }
            LOG.error("[结束接收参数]");

            String orderid = request.getParameter("orderid");
            String transid = request.getParameter("transid");
            String channel = request.getParameter("channel");
            String appid = request.getParameter("appid");
            String ordername = request.getParameter("ordername");
            String price = request.getParameter("price");
            String userid = request.getParameter("userid");
            String username = request.getParameter("username");
            String attach = request.getParameter("attach");
            String status = request.getParameter("status");
            String sandbox = request.getParameter("sandbox ");
            String createat = request.getParameter("createat");
            String startat = request.getParameter("startat");
            String payat = request.getParameter("payat");
            String sign = request.getParameter("sign");

            if (!"5".equals(status)) {
                LOG.error("交易失败");
                return "error";
            }

            // 所有参数按键先后排序组装,然后进行RSA签名验证
            String signcontent = getSignNation(params);
            LOG.error("[签名公钥]" + PUBLIC_KEY);

            boolean verify_result = RSA.verify(signcontent, sign, PUBLIC_KEY);
            LOG.error("[签名原文]" + signcontent);
            LOG.error("[签名结果]" + verify_result);

            if (!verify_result) {
                LOG.error("验签失败");
                return "error";
            }
            String[] v = orderid.split("_");
            if (v.length != 3) {
                LOG.error("传参不正确");
                return "error";
            }
            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = userid;
            payInfo.orderId = transid;

            payInfo.serialId = orderid + "-" + channel;    // channel:  1=微信，2=支付宝，3=AppStore 内购
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(price);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int retcode = payToGameServer(payInfo);
            if (retcode == 0) {
                LOG.error("返回充值成功");
                return "SUCCESS";
            } else {
                if (retcode == 1) {
                    LOG.error("重复订单");
                    return "SUCCESS";
                }
                LOG.error("返回充值失败" + retcode);
                return "error";
            }
        } catch (Exception e) {
            LOG.error("支付异常:" + e.getMessage());
            e.printStackTrace();
            return "error";
        }

    }

    public static String getSignNation(Map<String, String> params) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;

        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("sign") || k.equals("plat")) {
                continue;
            }

            if (params.get(k) == null) {
                continue;
            }
            v = (String) params.get(k);

            if (str.equals("")) {
                str = k + "=" + v;
            } else {
                str = str + "&" + k + "=" + v;
            }
        }
        return str;
    }


    private boolean verifyAccount(String[] param) {
        LOG.error("chdgfb_appstore 开始调用sidInfo接口");
        String signSource = param[0] + param[1];// 组装签名原文
        String sign = MD5.md5Digest(signSource).toLowerCase();
        LOG.error("[签名原文]" + signSource);
        LOG.error("[签名结果]" + sign);

        try {
            if (sign.equals(param[2])) {// 成功
                LOG.error("chdgfb_appstore 登陆成功");
                return true;
            } else {
                LOG.error("chdgfb_appstore 登陆失败");
                return false;
            }
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("chdgfb_appstore 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }

    }
}
