package com.account.plat.impl.mzYiwanCyzcAppstore;

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
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class MzYiwanCyzcAppstorePlat extends PlatBase {
    private static String TokenKey;
    private static String PayKey;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/mzYiwanCyzcAppstore/", "plat.properties");
        TokenKey = properties.getProperty("TokenKey");
        PayKey = properties.getProperty("PayKey");
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
    public String payBack(WebRequest request, String content,
                          HttpServletResponse response) {
        LOG.error("pay mzYiwanCyzc_appstore ");
        LOG.error("pay mzYiwanCyzc_appstore  content:" + content);
        LOG.error("[开始参数]");
        try {
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + request.getParameter(paramName));
            }
            LOG.error("[结束参数]");

            String game_id = request.getParameter("game_id");
            String out_trade_no = request.getParameter("out_trade_no");
            String price = request.getParameter("price");
            String extend = request.getParameter("extend");
            String sign = request.getParameter("sign");

            // 签名md5(game_id + out_trade_no + price+extend + key)
            String checkSign = MD5.md5Digest(game_id + out_trade_no + price + extend + PayKey);

            if (!checkSign.equals(sign)) {
                LOG.error("签名验证失败, checkSign:" + checkSign);
                return "1";
            }

            String[] v = extend.split("__");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = v[3];
            payInfo.orderId = out_trade_no;
            payInfo.serialId = v[0] + "__" + v[1] + "__" + v[2];
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);

            payInfo.realAmount = Double.valueOf(price);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);

            if (code == 0) {
                LOG.error("mzYiwanCyzc_appstore  充值发货成功！！ " + code);
            } else if (code == 1) {
                LOG.error("mzYiwanCyzc_appstore  重复的订单！！ " + code);
            } else {
                LOG.error("mzYiwanCyzc_appstore  充值发货失败！！ " + code);
            }
            return "1";
        } catch (Exception e) {
            LOG.error("mzYiwanCyzc_appstore  充值异常:" + e.getMessage());
            e.printStackTrace();
            return "1";
        }
    }

    private boolean verifyAccount(String uid, String token) {
        LOG.error("mzYiwanCyzc_appstore  开始调用sidInfo接口");
        try {
            String tokenStr = uid + TokenKey;
            LOG.error("签名原串:" + tokenStr);
            String tokenCheck = MD5.md5Digest(tokenStr);
            LOG.error("签名:" + tokenCheck);
            if (tokenCheck.equals(token)) {
                LOG.error("验证成功");
                return true;
            }
            return false;
        } catch (Exception e) {
            LOG.error("接口返回异常");
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }

    }
}
