package com.account.plat.impl.mztkjjAppstore;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
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
import com.account.plat.impl.muzhi.Rsa;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

//class UcAccount {
//	public int ucid;
//	public String nickName;
//}

@Component
public class MztkjjAppstorePlat extends PlatBase {
    // sdk server的接口地址
    private static String VERIRY_URL_SANBOX = "";
    private static String VERIRY_URL = "";

    // 游戏编号
    private static String AppID;

    private static String AppKey;

    private static Map<Integer, String> RECHARGE_MAP = new HashMap<Integer, String>();
    private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/mztkjjAppstore/", "plat.properties");

        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");

        VERIRY_URL = properties.getProperty("VERIRY_URL");
        VERIRY_URL_SANBOX = properties.getProperty("VERIRY_URL_SANBOX");
        initRechargeMap();
    }

    private void initRechargeMap() {
        RECHARGE_MAP.put(1, "com.Jrutech.Tank.Produc01.new5");
        MONEY_MAP.put(1, 6);

        RECHARGE_MAP.put(2, "com.Jrutech.Tank.Produc02.new5");
        MONEY_MAP.put(2, 30);

        RECHARGE_MAP.put(3, "com.Jrutech.Tank.Produc03.new5");
        MONEY_MAP.put(3, 98);

        RECHARGE_MAP.put(4, "com.Jrutech.Tank.Produc04.new5");
        MONEY_MAP.put(4, 198);

        RECHARGE_MAP.put(5, "com.Jrutech.Tank.Produc05.new5");
        MONEY_MAP.put(5, 328);

        RECHARGE_MAP.put(6, "com.Jrutech.Tank.Produc06.new5");
        MONEY_MAP.put(6, 648);
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
        String userName = vParam[1];
        String sign = vParam[2];

        if (!verifyAccount(userId, userName, sign)) {
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
        LOG.error("[pay mztkjj appstorePlat content]:" + content);

        try {
            content = URLDecoder.decode(content, "UTF-8");
            content = content.substring(content.indexOf("{"), content.lastIndexOf("}") + 1);
            content = content.replace("=", "");

            JSONObject json = JSONObject.fromObject(content);

            JSONObject params = new JSONObject();
            params.put("receipt-data", json.getString("receipt-data"));
            String body = params.toString();
            LOG.error("[请求参数]" + body);

            String result = HttpUtils.sentPost(VERIRY_URL, body);
            LOG.error("[appstore 返回]" + result);
            JSONObject rsp = JSONObject.fromObject(result);
            int status = rsp.getInt("status");
            if (status != 0) {
                LOG.error("form status error");
                result = HttpUtils.sentPost(VERIRY_URL_SANBOX, body);
                JSONObject rsp1 = JSONObject.fromObject(result);
                LOG.error("[沙箱 返回]" + rsp1.getInt("status"));
                if (rsp1.getInt("status") != 0) {
                    return "FAILURE";
                }
                rsp = rsp1;
            }

            JSONObject receipt = rsp.getJSONObject("receipt");
            // String item_id = receipt.getString("item_id");
            String product_id = receipt.getString("product_id");
            String transaction_id = receipt.getString("transaction_id");

            int rechargeId = json.getInt("rechargeId");
            int serverId = json.getInt("serverId");
            long roleId = json.getInt("playerId");
            String orderId = json.getString("orderId");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = json.getString("userId");
            payInfo.orderId = transaction_id;
            payInfo.serialId = orderId;
            payInfo.serverId = serverId;
            payInfo.roleId = roleId;

            if (!product_id.equals(RECHARGE_MAP.get(rechargeId))) {
                LOG.error("rechargeId abnormal!!!");
                return "FAILURE";
            }

            int money = MONEY_MAP.get(rechargeId);
            payInfo.realAmount = Double.valueOf(money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("muzhi appstore 充值发货失败！！ " + code);
                return "0|" + (System.currentTimeMillis() / 1000);
            }

            return "1|" + (System.currentTimeMillis() / 1000);
        } catch (Exception e) {
            LOG.error("muzhi appstore 充值异常！！ ");
            e.printStackTrace();
            return "0|" + (System.currentTimeMillis() / 1000);
        }
    }

    private boolean verifyAccount(String userId, String usename, String sign) {
        LOG.error("mztkjj appStore 开始调用sidInfo接口");
        try {
            String signSource = usename + AppKey;
            signSource = URLEncoder.encode(signSource, "utf-8");
            String signGenerate = Rsa.getMD5(signSource).toLowerCase();

            LOG.error("[签名原文]" + signSource);
            LOG.error("[签名结果]" + signGenerate);
            LOG.error("[签名传入]" + sign);

            if (sign.equals(signGenerate)) {
                return true;
            }
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        return false;

    }

}
