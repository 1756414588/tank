package com.account.plat.impl.chHj4Hw;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.muzhiJh.HttpUtils;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

import net.sf.json.JSONObject;

@Component
public class ChHj4HwPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static String APP_ID;

    private static String APP_KEY = "";

    private static String PUBLIC_KEY = "";

    private static String PRIVATE_KEY = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chHj4Hw/", "plat.properties");
        APP_ID = properties.getProperty("APP_ID");
        APP_KEY = properties.getProperty("APP_KEY");
        PUBLIC_KEY = properties.getProperty("PUBLIC_KEY");
        PRIVATE_KEY = properties.getProperty("PRIVATE_KEY");
        serverUrl = properties.getProperty("VERIRY_URL");
    }

    @Override
    public String order(WebRequest request, String content) {
        try {
            JSONObject result = new JSONObject();
            result.put("privateKey", PRIVATE_KEY);
            return result.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
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
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String access_token = vParam[0];
        String roleId = vParam[1];

        if (vParam.length == 2) {
            if (!verifyAccount(roleId, access_token)) {
                return GameError.SDK_LOGIN;
            }
        } else if (vParam.length == 3) {
            String ts = vParam[2];
            if (!verifyAccount(roleId, ts, access_token)) {
                return GameError.SDK_LOGIN;
            }
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), roleId);

        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(roleId);
            account.setAccount(getPlatNo() + "_" + roleId);
            account.setPasswd(roleId);
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
        LOG.error("pay chHj4Hw");
        LOG.error("[接收参数]");
        Map<String, Object> params = new HashMap<String, Object>();
        JSONObject ret = new JSONObject();
        try {
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                String paramValue = request.getParameter(paramName);
                if (paramName.equals("signType")) {
                    continue;
                }
                params.put(paramName, paramValue);
                LOG.error(paramName + ":" + paramValue);
            }
            LOG.error("[结束参数]");

            String orderId = request.getParameter("orderId");
            String extReserved = request.getParameter("extReserved");
            String amount = request.getParameter("amount");
            String result = request.getParameter("result");
            String sign = request.getParameter("sign");

            if (result == null || !result.equals("0")) {
                ret.put("result", 3);
                return ret.toString();
            }
            String origin = RSA.getSignData(params);
            LOG.error("[签名原文]" + origin);
            LOG.error("[sign]" + sign);
            if (!RSA.doCheck(origin, sign, APP_KEY)) {
                LOG.error("验签失败");
                ret.put("result", 1);
                return ret.toString();
            }

            String[] infos = extReserved.split("_");
            if (infos.length != 4) {
                LOG.error("传参不正确");
                ret.put("result", 95);
                return ret.toString();
            }
            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);
            String platId = infos[3];

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = platId;
            payInfo.orderId = orderId;

            payInfo.serialId = serverid + "_" + lordId + "_" + orderId;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(amount);
            payInfo.amount = (int) payInfo.realAmount;
            int retcode = payToGameServer(payInfo);
            if (retcode == 0) {
                LOG.error("chHj4Hw 返回充值成功");
            } else {
                LOG.error("chHj4Hw 充值成功,发货失败" + retcode);
            }
            ret.put("result", 0);
        } catch (Exception e) {
            e.printStackTrace();
            LOG.error("chHj4Hw 支付异常");
            ret.put("result", 94);
        }
        return ret.toString();
    }

    private boolean verifyAccount(String userId, String ts, String sign) {
        LOG.error("chHj4Hw 开始调用sidInfo接口");
        try {
            String checkSign = APP_ID + ts + userId;
            LOG.error(APP_ID);
            LOG.error(ts);
            LOG.error(userId);
            LOG.error(checkSign);
            LOG.error(PUBLIC_KEY);

            if (RSAUtil.verify(checkSign.getBytes("UTF-8"), PUBLIC_KEY, sign)) {
                LOG.error("chHj4Hw 登陆成功");
                return true;
            } else {
                LOG.error("chHj4Hw 登陆验签失败");
                return false;
            }
        } catch (Exception e) {
            LOG.error("chHj4Hw 登陆验签异常");
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("chHj4Hw 调用sidInfo接口结束");
        }
    }

    private boolean verifyAccount(String userId, String access_token) {
        LOG.error("chHj4Hw 开始调用sidInfo接口");
        try {
            access_token = URLEncoder.encode(access_token, "utf-8");
            access_token = access_token.replace("+", "%2B");
        } catch (UnsupportedEncodingException e1) {
            e1.printStackTrace();
        }

        Map<String, String> parameter = new HashMap<>();
        parameter.put("nsp_svc", "OpenUP.User.getInfo");
        parameter.put("nsp_ts", String.valueOf(System.currentTimeMillis() / 1000));
        parameter.put("access_token", access_token);

        LOG.error("[请求参数]" + parameter.toString());
        LOG.error("[请求地址]" + serverUrl);

        String result = HttpUtils.sendGet(serverUrl, parameter);
        LOG.error("[响应结果]" + result);
        if (result == null) {
            return false;
        }
        try {
            JSONObject rsp = JSONObject.fromObject(result);
            if (rsp.containsKey("userID")) {
                String uid = rsp.getString("userID");
                if (uid.equals(userId)) {
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            LOG.error("chHj4Hw 接口返回异常");
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("chHj4Hw 调用sidInfo接口结束");
        }
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return null;
    }

    public static void main(String[] args) {
        if (!RSA.doCheck(
                "amount=10.00&notifyTime=1500605458239&orderId=WX17100047341A1500540152549&payType=17&productName=金币&requestId=1500540152549&result=0&sysReserved=oU-eis8wIauobVqglj8xhHVwyYGg&userName=890086000001007296",
                "H9ihBLdeQpoEefcwuOdJr9OK1Oh6JjjOme+skrB/I7Vyo/JvXBkQBwysPz2Rpch/NEyR2BsmFEFK5bYYdiiqUfxRxiLgNvrvDTn5Zh2U4+u2aDPHMHML3M/aYoJdQ7yXK3Rr8ioQaYgq7shkyD5In//HzSJ5tPNzup2C0q6HmsAKpYdmaZHlewRNIkO4QToGjiMEyZVnPp7zqtFcEHNQ1fwqBML0ZehDTIflU+QpZH8lf+DeZIzpxn+Pd3WdfdGNz/IXHHfHB2mAHAKSxXQw+uVaFcdbTTJ0Y6kLlMj2ext5wL32Rist+Wh3LrQOqw0a8HQRk6B3VS1GqTUOKPYYvg==",
                "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlEDRNBLhaP1dAUH7R19i2VKb58IcACHCOu2Y8tGJkUD7x49XaqoP9wzq2kV5bCFnNvvrOMIXBhBxZN9pVkkPssKUzu/N4c8KHTwvvtp16a/ZfodNpvkwL1w5lytezrQ+pc+V6DoTF1Lgf8jC9jnCzX+fn2JlULI3nhOs/r9nlz3NhBR8ifDVIuyq6tzvcP0rzNV3Zj+dvpCCJrfANTVxZZGR7WYMmZ/xs4dpgWb8kYOEPBNlT0WvCKgdhyewjWKJJZdeer1nSYLVlHWWt9gwv6k00bcG9VVPNv7clHLOx5jkVEgoEk6IKIPTMrFMVgvfInw9q5OcfgLWH7VqWPb/NQIDAQAB")) {
            //LOG.error("验签失败");
        }
    }
}
