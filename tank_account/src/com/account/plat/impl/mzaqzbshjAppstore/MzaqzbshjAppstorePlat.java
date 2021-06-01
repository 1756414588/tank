package com.account.plat.impl.mzaqzbshjAppstore;

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
public class MzaqzbshjAppstorePlat extends PlatBase {
    private static String AppID;
    // private static String AppKey;
    private static String SecretKey;
    private static String VERIFY_URL;

    // private static Map<Integer, String> RECHARGE_MAP = new HashMap<Integer, String>();
    // private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/mzaqzbshjAppstore/", "plat.properties");
        AppID = properties.getProperty("AppID");
        // AppKey = properties.getProperty("AppKey");
        SecretKey = properties.getProperty("SecretKey");
        VERIFY_URL = properties.getProperty("VERIFY_URL");
        // initRechargeMap();
    }

    // private void initRechargeMap() {
    // RECHARGE_MAP.put(1, "com.muzhi.tank60");
    // MONEY_MAP.put(1, 6);
    //
    // RECHARGE_MAP.put(2, "com.muzhi.tank300");
    // MONEY_MAP.put(2, 30);
    //
    // RECHARGE_MAP.put(3, "com.muzhi.tank980");
    // MONEY_MAP.put(3, 98);
    //
    // RECHARGE_MAP.put(4, "com.muzhi.tank1980");
    // MONEY_MAP.put(4, 198);
    //
    // RECHARGE_MAP.put(5, "com.muzhi.tank3280");
    // MONEY_MAP.put(5, 328);
    //
    // RECHARGE_MAP.put(6, "com.muzhi.tank6480");
    // MONEY_MAP.put(6, 648);
    // }

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
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String uid = vParam[0];

        if (!verifyAccount(vParam[0], vParam[1])) {
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

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay mzAqZbshj_appstore ");
        LOG.error("pay mzAqZbshj_appstore  content:" + content);
        LOG.error("[开始参数]");
        try {
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + request.getParameter(paramName));
            }
            LOG.error("[结束参数]");

            String uid = request.getParameter("uid");
            String cporder = request.getParameter("cporder");
            String cpappid = request.getParameter("cpappid");
            String money = request.getParameter("money");
            String order = request.getParameter("order");
            String sign = request.getParameter("sign");

            // $str = md5($uid.$cporder.$money.$order.$app_secret);
            String checkSign = MD5.md5Digest(uid + cporder + money + order + SecretKey);

            if (!checkSign.equals(sign)) {
                LOG.error("签名验证失败, checkSign:" + checkSign);
                return "fail";
            }

            if (!cpappid.equals(AppID)) {
                LOG.error("AppId无效, cpappid:" + cpappid);
                return "fail";
            }

            String[] v = cporder.split("_");
            int rechargeId = Integer.valueOf(v[3]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = uid;
            payInfo.orderId = order;

            payInfo.serialId = cporder;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);

            payInfo.realAmount = Double.valueOf(money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                if (code == 1) {
                    LOG.error("mzAqZbshj_appstore  重复的订单！！ " + code);
                    return "success";
                }
                LOG.error("mzAqZbshj_appstore  充值发货失败！！ " + code);
                return "fail";
            } else {
                LOG.error("mzAqZbshj_appstore  充值发货成功！！ " + code);
                return "success";
            }
        } catch (Exception e) {
            LOG.error("mzAqZbshj_appstore  充值异常:" + e.getMessage());
            e.printStackTrace();
            return "fail";
        }
    }

    private boolean verifyAccount(String uid, String token) {
        LOG.error("mzAqZbshj_appstore  开始调用sidInfo接口");
        try {
            StringBuffer sb = new StringBuffer();
            String sign = MD5.md5Digest(uid + token + AppID + SecretKey);
            sb.append(VERIFY_URL);
            sb.append("/uid/").append(uid);
            sb.append("/vkey/").append(token);
            sb.append("/appid/").append(AppID);
            sb.append("/sign/").append(sign);
            LOG.error("需要发送到服务器的数据为：" + sb.toString());
            String result = HttpUtils.sendGet(sb.toString(), new HashMap<String, String>());
            LOG.error("[响应结果]" + result);

            JSONObject rsp = JSONObject.fromObject(result);
            String status = rsp.getString("status");
            if (!"0".equals(status)) {
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
}
