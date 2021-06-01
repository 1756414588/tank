package com.account.plat.impl.mzenAppstore;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.muzhi.Rsa;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.*;

//class UcAccount {
//	public int ucid;
//	public String nickName;
//}

@Component
public class MzenAppstorePlat extends PlatBase {
    // sdk server的接口地址
    private static String VERIRY_URL_SANBOX = "";
    private static String VERIRY_URL = "";

    // 游戏编号
    private static String AppID;

    private static String AppKey;

    private static Map<String, Integer> RECHARGE_MAP = new HashMap<String, Integer>();
    private static Map<String, Double> RECHARGE_PRICE_MAP = new HashMap<String, Double>();
    private static Map<String, Integer> PACK_MAP = new HashMap<String, Integer>();
    private static Map<String, Double> PACK_PRICE_MAP = new HashMap<String, Double>();

    private static Map<Integer, Integer> RECHARGE_MAP_OTHER = new HashMap<Integer, Integer>();
    private static Map<Integer, Double> RECHARGE_PRICE_MAP_OTHER = new HashMap<Integer, Double>();
    private static Map<Integer, Double> PACK_PRICE_MAP_OTHER = new HashMap<Integer, Double>();

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/mzenAppstore/", "plat.properties");

        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");

        VERIRY_URL = properties.getProperty("VERIRY_URL");
        VERIRY_URL_SANBOX = properties.getProperty("VERIRY_URL_SANBOX");
        initRechargeMap();
    }

    private void initRechargeMap() {
        RECHARGE_MAP.put("com.MZYW.tankejingjie_300", 30);
        RECHARGE_PRICE_MAP.put("com.MZYW.tankejingjie_300", 4.99);
        RECHARGE_MAP_OTHER.put(1, 30);
        RECHARGE_PRICE_MAP_OTHER.put(1, 4.99);

        RECHARGE_MAP.put("com.MZYW.tankejingjie_680", 68);
        RECHARGE_PRICE_MAP.put("com.MZYW.tankejingjie_680", 9.99);
        RECHARGE_MAP_OTHER.put(2, 68);
        RECHARGE_PRICE_MAP_OTHER.put(2, 9.99);

        RECHARGE_MAP.put("com.MZYW.tankejingjie_1280", 128);
        RECHARGE_PRICE_MAP.put("com.MZYW.tankejingjie_1280", 19.99);
        RECHARGE_MAP_OTHER.put(3, 128);
        RECHARGE_PRICE_MAP_OTHER.put(3, 19.99);

        RECHARGE_MAP.put("com.MZYW.tankejingjie_3280", 328);
        RECHARGE_PRICE_MAP.put("com.MZYW.tankejingjie_3280", 49.99);
        RECHARGE_MAP_OTHER.put(4, 328);
        RECHARGE_PRICE_MAP_OTHER.put(4, 49.99);

        RECHARGE_MAP.put("com.MZYW.tankejingjie_6480", 648);
        RECHARGE_PRICE_MAP.put("com.MZYW.tankejingjie_6480", 99.99);
        RECHARGE_MAP_OTHER.put(5, 648);
        RECHARGE_PRICE_MAP_OTHER.put(5, 99.99);

        PACK_MAP.put("com.MZYW.tankejingjie_pack1", 1);
        PACK_PRICE_MAP.put("com.MZYW.tankejingjie_pack1", 0.99);
        PACK_PRICE_MAP_OTHER.put(1, 0.99);

        PACK_MAP.put("com.MZYW.tankejingjie_pack4", 2);
        PACK_PRICE_MAP.put("com.MZYW.tankejingjie_pack4", 1.99);
        PACK_PRICE_MAP_OTHER.put(2, 1.99);

        PACK_MAP.put("com.MZYW.tankejingjie_pack7", 3);
        PACK_PRICE_MAP.put("com.MZYW.tankejingjie_pack7", 4.99);
        PACK_PRICE_MAP_OTHER.put(3, 4.99);

        PACK_MAP.put("com.MZYW.tankejingjie_pack10", 4);
        PACK_PRICE_MAP.put("com.MZYW.tankejingjie_pack10", 9.99);
        PACK_PRICE_MAP_OTHER.put(4, 9.99);

        PACK_MAP.put("com.MZYW.tankejingjie_pack13", 5);
        PACK_PRICE_MAP.put("com.MZYW.tankejingjie_pack13", 19.99);
        PACK_PRICE_MAP_OTHER.put(5, 19.99);

        PACK_MAP.put("com.MZYW.tankejingjie_6", 6);
        PACK_PRICE_MAP.put("com.MZYW.tankejingjie_pack13", 49.99);
        PACK_PRICE_MAP_OTHER.put(6, 49.99);

        PACK_MAP.put("com.MZYW.tankejingjie_7", 7);
        PACK_PRICE_MAP.put("com.MZYW.tankejingjie_pack13", 99.99);
        PACK_PRICE_MAP_OTHER.put(7, 99.99);

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
        LOG.error("[pay muzhi appstore content]:" + content);
        boolean flag = false;
        Iterator<String> it = request.getParameterNames();
        while (it.hasNext()) {
            String parameter = it.next();
            if (parameter.equals("sign")) {
                flag = true;
            }
            String v = request.getParameter(parameter);
            LOG.error(parameter + "=" + v);
        }
        try {
            if (flag) {// 拇指充值
                String sign = request.getParameter("sign");
                String body = request.getParameter("content");
                body = new String(Base64.decode(body));
                String mysign = Rsa.getMD5(body + "&key=" + AppKey);
                LOG.error("[content]" + body);
                LOG.error("[签名结果]" + mysign + "|" + sign);
                if (!mysign.equals(sign)) {// 签名正确,做业务逻辑处理
                    LOG.error("签名失败");
                    return "fail";
                }
                JSONObject json = JSONObject.fromObject(body);
                String pay_no = json.getString("pay_no");
                String username = json.getString("username");
                String device_id = json.getString("device_id");
                String server_id = json.getString("server_id");
                String game_id = json.getString("game_id");
                String cp_order_id = json.getString("cp_order_id");
                String pay_type = json.getString("pay_type");
                int amount = json.getInt("amount");
                int payStatus = json.getInt("payStatus");
                int user_id = json.getInt("user_id");
                if (payStatus != 0) {
                    LOG.error("充值未完成");
                    return "fail";
                }

                // if (payStatus == 0) {
                // 1.下发游戏币,玩家实际付费以本通知的amount为准，不能使用订单生成的金额。
                // 2.成功与否都返回success，SDK服务器只关心是否有通知到CP服务器
                String[] info = cp_order_id.split("_");
                if (info.length < 5) {
                    LOG.error("自由参数不正确");
                    return "success";
                }

                int rechargeId = Integer.valueOf(info[3]);
                int rechargePackId = Integer.valueOf(info[4]);

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.platId = String.valueOf(user_id);
                payInfo.orderId = pay_no;
                payInfo.serialId = cp_order_id;
                payInfo.serverId = Integer.parseInt(info[0]);
                payInfo.roleId = Long.parseLong(info[1]);

                if (rechargeId > 0) { // 购买金币
                    payInfo.realAmount = RECHARGE_PRICE_MAP_OTHER.get(rechargeId);
                    payInfo.amount = RECHARGE_MAP_OTHER.get(rechargeId);
                } else if (rechargePackId > 0) { // 购买礼包
                    payInfo.realAmount = PACK_PRICE_MAP_OTHER.get(rechargePackId);
                    payInfo.packId = rechargePackId;
                }
                int code = payToGameServer(payInfo);
                if (code != 0) {
                    LOG.error("muzhi appstore 充值发货失败！！ " + code);
                } else {
                    LOG.error("muzhi appstore 充值发货成功！！ ");
                }
                return "success";

            } else {// 到苹果方进行票据验证
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

                Integer money = RECHARGE_MAP.get(product_id);
                Integer packId = PACK_MAP.get(product_id);

                if (money == null && packId == null) {
                    LOG.error("rechargeId abnormal!!!");
                    return "FAILURE";
                }

                if (json.containsKey("MuZhiOrderId")) {
                    transaction_id = json.getString("MuZhiOrderId");
                }

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.platId = json.getString("userId");
                payInfo.orderId = transaction_id;
                payInfo.serialId = orderId;
                payInfo.serverId = serverId;
                payInfo.roleId = roleId;
                if (money != null) { // 购买金币
                    payInfo.realAmount = RECHARGE_PRICE_MAP.get(product_id);
                    payInfo.amount = (int) (Double.valueOf(money) / 1);
                } else if (packId != null) { // 购买礼包
                    payInfo.realAmount = PACK_PRICE_MAP.get(product_id);
                    payInfo.packId = packId;
                }

                int code = payToGameServer(payInfo);
                if (code != 0) {
                    LOG.error("muzhi appstore 充值发货失败！！ " + code);
                    return "0|" + (System.currentTimeMillis() / 1000);
                }

            }

            return "1|" + (System.currentTimeMillis() / 1000);
        } catch (Exception e) {
            LOG.error("muzhi appstore 充值异常！！ ");
            e.printStackTrace();
            return "0|" + (System.currentTimeMillis() / 1000);
        }
    }

    private boolean verifyAccount(String userId, String usename, String sign) {
        LOG.error("muzhi appStore 开始调用sidInfo接口");
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

    public static void main(String[] args) {
        String content = "plat=mz_appstore&%7B%22receipt-data%22%3A%22ewoJInNpZ25hdHVyZSIgPSAiQXlBNXNHS1NjeTBLZGI3U3FvbmpNQ2xVaHJoYUlpeElRTnBpdnI4L2hzejNqUHA4MHlLbWN0bCs1MWxrbW5QazhaM0Ivb1lOMXpUbllWNzNUaUJ3SUtrU2FUT3I0eDVuVGNjWGZuelV6eURUUGhtbTlTRnV6SVVBemxaVUNYbTNXWFlJbXJUNjZvM003YTB5T2I2WHFSVEpHMHdGdXF5L2hxVXpLaUpHZzJIOUdsTzdQZ2F3WVpxYkRQWlRDT2RCUzVyQVVtWTJnL3JlNUM3aFhqakNJTGhaUTRZQVpZNWE1K1RsQzVoNUpTY0JnRjBJdEVwWk1jNm5CbWdrSzA1eTJnZmNMbDZzdzg5YXJmSFdFc2lsQ0hwUUoydytrenBzZHBJR3k5dWtPcnBzeXp0Rjd6V1lhMVFTRWdhckJKNC9MVCtFdUg3L0ZRdm9LblpYcGlHOWxsa0FBQVdBTUlJRmZEQ0NCR1NnQXdJQkFnSUlEdXRYaCtlZUNZMHdEUVlKS29aSWh2Y05BUUVGQlFBd2daWXhDekFKQmdOVkJBWVRBbFZUTVJNd0VRWURWUVFLREFwQmNIQnNaU0JKYm1NdU1Td3dLZ1lEVlFRTERDTkJjSEJzWlNCWGIzSnNaSGRwWkdVZ1JHVjJaV3h2Y0dWeUlGSmxiR0YwYVc5dWN6RkVNRUlHQTFVRUF3dzdRWEJ3YkdVZ1YyOXliR1IzYVdSbElFUmxkbVZzYjNCbGNpQlNaV3hoZEdsdmJuTWdRMlZ5ZEdsbWFXTmhkR2x2YmlCQmRYUm9iM0pwZEhrd0hoY05NVFV4TVRFek1ESXhOVEE1V2hjTk1qTXdNakEzTWpFME9EUTNXakNCaVRFM01EVUdBMVVFQXd3dVRXRmpJRUZ3Y0NCVGRHOXlaU0JoYm1RZ2FWUjFibVZ6SUZOMGIzSmxJRkpsWTJWcGNIUWdVMmxuYm1sdVp6RXNNQ29HQTFVRUN3d2pRWEJ3YkdVZ1YyOXliR1IzYVdSbElFUmxkbVZzYjNCbGNpQlNaV3hoZEdsdmJuTXhFekFSQmdOVkJBb01Da0Z3Y0d4bElFbHVZeTR4Q3pBSkJnTlZCQVlUQWxWVE1JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBcGMrQi9TV2lnVnZXaCswajJqTWNqdUlqd0tYRUpzczl4cC9zU2cxVmh2K2tBdGVYeWpsVWJYMS9zbFFZbmNRc1VuR09aSHVDem9tNlNkWUk1YlNJY2M4L1cwWXV4c1FkdUFPcFdLSUVQaUY0MWR1MzBJNFNqWU5NV3lwb041UEM4cjBleE5LaERFcFlVcXNTNCszZEg1Z1ZrRFV0d3N3U3lvMUlnZmRZZUZScjZJd3hOaDlLQmd4SFZQTTNrTGl5a29sOVg2U0ZTdUhBbk9DNnBMdUNsMlAwSzVQQi9UNXZ5c0gxUEttUFVockFKUXAyRHQ3K21mNy93bXYxVzE2c2MxRkpDRmFKekVPUXpJNkJBdENnbDdaY3NhRnBhWWVRRUdnbUpqbTRIUkJ6c0FwZHhYUFEzM1k3MkMzWmlCN2o3QWZQNG83UTAvb21WWUh2NGdOSkl3SURBUUFCbzRJQjF6Q0NBZE13UHdZSUt3WUJCUVVIQVFFRU16QXhNQzhHQ0NzR0FRVUZCekFCaGlOb2RIUndPaTh2YjJOemNDNWhjSEJzWlM1amIyMHZiMk56Y0RBekxYZDNaSEl3TkRBZEJnTlZIUTRFRmdRVWthU2MvTVIydDUrZ2l2Uk45WTgyWGUwckJJVXdEQVlEVlIwVEFRSC9CQUl3QURBZkJnTlZIU01FR0RBV2dCU0lKeGNKcWJZWVlJdnM2N3IyUjFuRlVsU2p0ekNDQVI0R0ExVWRJQVNDQVJVd2dnRVJNSUlCRFFZS0tvWklodmRqWkFVR0FUQ0IvakNCd3dZSUt3WUJCUVVIQWdJd2diWU1nYk5TWld4cFlXNWpaU0J2YmlCMGFHbHpJR05sY25ScFptbGpZWFJsSUdKNUlHRnVlU0J3WVhKMGVTQmhjM04xYldWeklHRmpZMlZ3ZEdGdVkyVWdiMllnZEdobElIUm9aVzRnWVhCd2JHbGpZV0pzWlNCemRHRnVaR0Z5WkNCMFpYSnRjeUJoYm1RZ1kyOXVaR2wwYVc5dWN5QnZaaUIxYzJVc0lHTmxjblJwWm1sallYUmxJSEJ2YkdsamVTQmhibVFnWTJWeWRHbG1hV05oZEdsdmJpQndjbUZqZEdsalpTQnpkR0YwWlcxbGJuUnpMakEyQmdnckJnRUZCUWNDQVJZcWFIUjBjRG92TDNkM2R5NWhjSEJzWlM1amIyMHZZMlZ5ZEdsbWFXTmhkR1ZoZFhSb2IzSnBkSGt2TUE0R0ExVWREd0VCL3dRRUF3SUhnREFRQmdvcWhraUc5Mk5rQmdzQkJBSUZBREFOQmdrcWhraUc5dzBCQVFVRkFBT0NBUUVBRGFZYjB5NDk0MXNyQjI1Q2xtelQ2SXhETUlKZjRGelJqYjY5RDcwYS9DV1MyNHlGdzRCWjMrUGkxeTRGRkt3TjI3YTQvdncxTG56THJSZHJqbjhmNUhlNXNXZVZ0Qk5lcGhtR2R2aGFJSlhuWTR3UGMvem83Y1lmcnBuNFpVaGNvT0FvT3NBUU55MjVvQVE1SDNPNXlBWDk4dDUvR2lvcWJpc0IvS0FnWE5ucmZTZW1NL2oxbU9DK1JOdXhUR2Y4YmdwUHllSUdxTktYODZlT2ExR2lXb1IxWmRFV0JHTGp3Vi8xQ0tuUGFObVNBTW5CakxQNGpRQmt1bGhnd0h5dmozWEthYmxiS3RZZGFHNllRdlZNcHpjWm04dzdISG9aUS9PamJiOUlZQVlNTnBJcjdONFl0UkhhTFNQUWp2eWdhWndYRzU2QWV6bEhSVEJoTDhjVHFBPT0iOwoJInB1cmNoYXNlLWluZm8iID0gImV3b0pJbTl5YVdkcGJtRnNMWEIxY21Ob1lYTmxMV1JoZEdVdGNITjBJaUE5SUNJeU1ERTJMVEEzTFRFeklESXpPalV4T2pJNElFRnRaWEpwWTJFdlRHOXpYMEZ1WjJWc1pYTWlPd29KSW5CMWNtTm9ZWE5sTFdSaGRHVXRiWE1pSUQwZ0lqRTBOamcwTnprd09EZ3pPVElpT3dvSkluVnVhWEYxWlMxcFpHVnVkR2xtYVdWeUlpQTlJQ0psTW1GaFl6Wm1Oak15T1RBM09EUTNNbVZrTVRFMFpEY3pZbUUxWlRFNE16Tm1NbVpqTmpJd0lqc0tDU0p2Y21sbmFXNWhiQzEwY21GdWMyRmpkR2x2YmkxcFpDSWdQU0FpTlRFd01EQXdNVEkzTVRJMk5qVXdJanNLQ1NKaWRuSnpJaUE5SUNJeUxqQXVNaUk3Q2draVlYQndMV2wwWlcwdGFXUWlJRDBnSWpFeE1ETTFOamN5TURnaU93b0pJblJ5WVc1ellXTjBhVzl1TFdsa0lpQTlJQ0kxTVRBd01EQXhNamN4TWpZMk5UQWlPd29KSW5GMVlXNTBhWFI1SWlBOUlDSXhJanNLQ1NKdmNtbG5hVzVoYkMxd2RYSmphR0Z6WlMxa1lYUmxMVzF6SWlBOUlDSXhORFk0TkRjNU1EZzRNemt5SWpzS0NTSjFibWx4ZFdVdGRtVnVaRzl5TFdsa1pXNTBhV1pwWlhJaUlEMGdJa1pDT1RjMVFUbEdMVEl5T0RRdE5FRTRSUzA0UWpZNExUSTJPVGxFTjBZM04wSXlNaUk3Q2draWFYUmxiUzFwWkNJZ1BTQWlNVEV3TlRjME9EYzBNQ0k3Q2draWRtVnljMmx2YmkxbGVIUmxjbTVoYkMxcFpHVnVkR2xtYVdWeUlpQTlJQ0k0TVRjM01EUTBPVE1pT3dvSkluQnliMlIxWTNRdGFXUWlJRDBnSW1OdmJTNXRkWHBvYVM1MFlXNXJPVGd3SWpzS0NTSndkWEpqYUdGelpTMWtZWFJsSWlBOUlDSXlNREUyTFRBM0xURTBJREEyT2pVeE9qSTRJRVYwWXk5SFRWUWlPd29KSW05eWFXZHBibUZzTFhCMWNtTm9ZWE5sTFdSaGRHVWlJRDBnSWpJd01UWXRNRGN0TVRRZ01EWTZOVEU2TWpnZ1JYUmpMMGROVkNJN0Nna2lZbWxrSWlBOUlDSmpiMjB1YlhWNmFHa3VkR0Z1YXlJN0Nna2ljSFZ5WTJoaGMyVXRaR0YwWlMxd2MzUWlJRDBnSWpJd01UWXRNRGN0TVRNZ01qTTZOVEU2TWpnZ1FXMWxjbWxqWVM5TWIzTmZRVzVuWld4bGN5STdDbjA9IjsKCSJwb2QiID0gIjUxIjsKCSJzaWduaW5nLXN0YXR1cyIgPSAiMCI7Cn0=%22%2C+%22serverId%22%3A%22167%22%2C+%22playerId%22%3A%2216707027%22%2C+%22orderId%22%3A%22167_16707027_20160714145105%22%2C+%22userId%22%3A%224404689%22%2C+%22rechargeId%22%3A%223%22%7D";
        try {
            content = URLDecoder.decode(content, "utf-8");
        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        content = "eyJwYXlfbm8iOiI2MDcxMzE0MDQ1ODEiLCJ1c2VybmFtZSI6Im0zMzAzOTMzOTciLCJ1c2VyX2lkIjo0NTA0MDUzLCJkZXZpY2VfaWQiOiIwNzEyMTgzMDIzMTQ1OTciLCJzZXJ2ZXJfaWQiOiIxNzUiLCJwYWNrZXRfaWQiOiIxMDAzOTEwMDEiLCJnYW1lX2lkIjoiMzkxIiwiY3Bfb3JkZXJfaWQiOiIxNzVfMTc1MDE4MzVfMjAxNjA3MTMxNDA0NTkiLCJwYXlfdHlwZSI6Imlvc3BheSIsImFtb3VudCI6NjAwLCJwYXlTdGF0dXMiOjB9";
        content = new String(Base64.decode(content));
        // LOG.error(content);
        // String mysign = Rsa.getMD5(content + "&key=zty391");
        // LOG.error(mysign);

    }
}
