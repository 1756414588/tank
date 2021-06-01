package com.account.plat.impl.inTouch;

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

@Component
public class InTouchPlat extends PlatBase {

    private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();
    private static String AppKey;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/inTouch/", "plat.properties");
        AppKey = properties.getProperty("AppKey");
        initRechargeMap();
    }

    private void initRechargeMap() {
        MONEY_MAP.put(1, 30);

        MONEY_MAP.put(2, 68);

        MONEY_MAP.put(3, 128);

        MONEY_MAP.put(4, 328);

        MONEY_MAP.put(5, 648);
    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion()
                || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        LOG.error("接收参数 sid:" + sid + " deviceNo:" + deviceNo
                + " baseVersion:" + baseVersion + " versionNo:" + versionNo);
        String[] vParam = sid.split("_");
        if (vParam.length < 1) {
            return GameError.PARAM_ERROR;
        }

        String uid = vParam[0];

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
    public String payBack(WebRequest request, String content,
                          HttpServletResponse response) {
        Iterator<String> iterator = request.getParameterNames();
        LOG.error("pay inTouch");
        LOG.error("pay inTouch content:" + content);
        while (iterator.hasNext()) {
            String paramName = iterator.next();
            LOG.error(paramName + ":" + request.getParameter(paramName));
        }
        LOG.error("[参数结束]");

        try {
            String Act = request.getParameter("Act");
            String AppId = request.getParameter("AppId");
            String ThirdAppId = request.getParameter("ThirdAppId");
            String Uin = request.getParameter("Uin");
            String ConsumeStreamId = request.getParameter("ConsumeStreamId");
            String TradeNo = request.getParameter("TradeNo");
            String Subject = request.getParameter("Subject");
            String Amount = request.getParameter("Amount");
            String ChargeAmount = request.getParameter("ChargeAmount");
            String ChargeAmountIncVAT = request.getParameter("ChargeAmountIncVAT");
            String ChargeAmountExclVAT = request.getParameter("ChargeAmountExclVAT");
            String Country = request.getParameter("Country");
            String Currency = request.getParameter("Currency");
            String Share = request.getParameter("Share");
            String Note = request.getParameter("Note");
            String TradeStatus = request.getParameter("TradeStatus");
            String CreateTime = request.getParameter("CreateTime");
            String IsTest = request.getParameter("IsTest");
            String PayChannel = request.getParameter("PayChannel");
            String Sign = request.getParameter("Sign");

            if (!TradeStatus.equals("0")) {
                LOG.error("inTouch 支付不成功" + TradeStatus);
                return packResponse(0);
            }

            String signSource = Act + AppId + ThirdAppId + Uin
                    + ConsumeStreamId + TradeNo + Subject + Amount
                    + ChargeAmount + ChargeAmountIncVAT + ChargeAmountExclVAT
                    + Country + Currency + Share + Note + TradeStatus
                    + CreateTime + IsTest + PayChannel + AppKey;

            String orginSign = MD5.md5Digest(signSource);

            if (orginSign.equals(Sign)) {
                String[] infos = Note.split("_");
                if (infos.length != 4) {
                    LOG.error("自有参数不正确");
                    return packResponse(0);
                }

                int serverid = Integer.valueOf(infos[0]);
                Long lordId = Long.valueOf(infos[1]);

                int rechargeId = Integer.valueOf(infos[3]);
                int money = MONEY_MAP.get(rechargeId);

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.platId = Uin;
                payInfo.orderId = ConsumeStreamId;

                payInfo.serialId = Note;
                payInfo.serverId = serverid;
                payInfo.roleId = lordId;
                payInfo.realAmount = Double.valueOf(ChargeAmountExclVAT);
                payInfo.amount = money;
                int code = payToGameServer(payInfo);

                if (code != 0) {
                    LOG.error("inTouch 充值发货失败 " + code);
                    return packResponse(0);
                } else {
                    LOG.error("inTouch 充值发货成功" + code);
                    return packResponse(1);
                }
            } else {
                LOG.error("inTouch 充值发货失败    Sign无效 ");
                return packResponse(5);  // 5：Sign无效
            }
        } catch (Exception e) {
            LOG.error("支付异常:" + e.getMessage());
            e.printStackTrace();
            return packResponse(0);
        }
    }

    private String packResponse(int ResultCode) {
        JSONObject json = new JSONObject();
        json.put("ErrorCode", ResultCode);
        if (ResultCode == 1) {
            json.put("ErrorDesc", "Success");
        } else {
            json.put("ErrorDesc", "Fail");
        }
        return json.toString();
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }

}
