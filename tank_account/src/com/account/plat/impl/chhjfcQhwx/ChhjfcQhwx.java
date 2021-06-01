package com.account.plat.impl.chhjfcQhwx;


import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.*;

@Component
public class ChhjfcQhwx extends PlatBase {


    private static String AppKey;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chhjfcQhwx/", "plat.properties");
        //AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;

    }

    @Override
    public int getPlatNo() {
        return 209;
    }


    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            LOG.error("GameError.PARAM_ERROR");
            return GameError.PARAM_ERROR;
        }
        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();
        String[] vParam = sid.split("_");
        if (vParam.length < 1) {
            LOG.error("vParam.length:" + vParam.length);
            return GameError.PARAM_ERROR;
        }
        String uid = vParam[0];
        Account account = accountDao.selectByPlatId(getPlatNo(), uid);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();

            account.setPlatNo(this.getPlatNo());
            account.setChildNo(super.getPlatNo());
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
            LOG.error("authorityRs:" + authorityRs);
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
        LOG.error("chhjfc_qhwx payBack开始");
        try {
            Map<String, String> map = UtilVerify.decryptData(request, AppKey);
            if (map == null || map.isEmpty()) {
                LOG.error("chhjfc_qhwx 参数错误");
                return "error";
            }
            String gameOrId = request.getParameter("gameOrderId");
            if (null != gameOrId) {
                String orderStatus = map.get("payStatus");
                if (!orderStatus.equals("2")) {
                    LOG.error("chhjfc_qhwx 订单状态不对 ,发货失败");
                    return "2";
                }
                String[] infos = gameOrId.split("_");
                if (infos.length < 3) {
                    return "3";
                }
                int serverId = Integer.valueOf(infos[0]);
                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.childNo = super.getPlatNo();
                payInfo.serialId = gameOrId;
                payInfo.platId = map.get("uid");
                payInfo.orderId = map.get("orderId");
                payInfo.serverId = serverId;
                payInfo.roleId = Long.parseLong(infos[1]);
                payInfo.realAmount = Integer.valueOf(map.get("payAmount")) / 100.0;
                payInfo.amount = Integer.valueOf(map.get("payAmount")) / 100;
                int code = payToGameServer(payInfo);
                LOG.error("chhjfc_qhwx 发货返回状态吗" + code);
                if (code == 0) {
                    return "ok";
                }
            }
            return "error";
        } catch (Exception e) {
            LOG.error("chhjfc_qhwx 充值异常！！ " + e.getMessage());
            e.printStackTrace();
            return "ERROR";
        }
    }
}
