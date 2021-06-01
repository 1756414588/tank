package com.account.plat.impl.mztkwzAppstore;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
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
import com.account.plat.impl.muzhi.Rsa;
import com.account.plat.impl.mzAppstore.Base64;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

//class UcAccount {
//	public int ucid;
//	public String nickName;
//}

@Component
public class MztkwzAppstorePlat extends PlatBase {
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
        Properties properties = loadProperties("com/account/plat/impl/mztkwzAppstore/", "plat.properties");

        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");

        VERIRY_URL = properties.getProperty("VERIRY_URL");
        VERIRY_URL_SANBOX = properties.getProperty("VERIRY_URL_SANBOX");
        initRechargeMap();
    }

    private void initRechargeMap() {
        RECHARGE_MAP.put(1, "com.Jrutech.Tank.Produc01.new1");
        MONEY_MAP.put(1, 6);

        RECHARGE_MAP.put(2, "com.Jrutech.Tank.Produc02.new1");
        MONEY_MAP.put(2, 30);

        RECHARGE_MAP.put(3, "com.Jrutech.Tank.Produc03.new1");
        MONEY_MAP.put(3, 98);

        RECHARGE_MAP.put(4, "com.Jrutech.Tank.Produc04.new1");
        MONEY_MAP.put(4, 198);

        RECHARGE_MAP.put(5, "com.Jrutech.Tank.Produc05.new1");
        MONEY_MAP.put(5, 328);

        RECHARGE_MAP.put(6, "com.Jrutech.Tank.Produc06.new1");
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
        LOG.error("[pay mztkwz appstore content]:" + content);
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
                if (info.length < 3) {
                    LOG.error("自由参数不正确");
                    return "success";
                }

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.platId = String.valueOf(user_id);
                payInfo.orderId = pay_no;
                payInfo.serialId = cp_order_id;
                payInfo.serverId = Integer.parseInt(info[0]);
                payInfo.roleId = Long.parseLong(info[1]);

                payInfo.realAmount = Double.valueOf(amount);
                payInfo.amount = (int) (payInfo.realAmount / 100);
                int code = payToGameServer(payInfo);
                if (code != 0) {
                    LOG.error("mztkwz appstore 充值发货失败！！ " + code);
                } else {
                    LOG.error("mztkwz appstore 充值发货成功！！ ");
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

                if (!product_id.equals(RECHARGE_MAP.get(rechargeId))) {
                    LOG.error("rechargeId abnormal!!!");
                    return "FAILURE";
                }

                int money = MONEY_MAP.get(rechargeId);
                payInfo.realAmount = Double.valueOf(money);
                payInfo.amount = (int) (payInfo.realAmount / 1);
                int code = payToGameServer(payInfo);
                if (code != 0) {
                    LOG.error("mztkwz appstore 充值发货失败！！ " + code);
                    return "0|" + (System.currentTimeMillis() / 1000);
                }

            }

            return "1|" + (System.currentTimeMillis() / 1000);

//			content = URLDecoder.decode(content, "UTF-8");
//			content = content.substring(content.indexOf("{"), content.lastIndexOf("}") + 1);
//			content = content.replace("=", "");
//			JSONObject json = JSONObject.fromObject(content);
//
//			JSONObject params = new JSONObject();
//			params.put("receipt-data", json.getString("receipt-data"));
//			String body = params.toString();
//			LOG.error("[请求参数]" + body);
//
//			String result = HttpUtils.sentPost(VERIRY_URL, body);
//			LOG.error("[appstore 返回]" + result);
//			JSONObject rsp = JSONObject.fromObject(result);
//			int status = rsp.getInt("status");
//			if (status != 0) {
//				LOG.error("form status error");
//				result = HttpUtils.sentPost(VERIRY_URL_SANBOX, body);
//				JSONObject rsp1 = JSONObject.fromObject(result);
//				LOG.error("[沙箱 返回]" + rsp1.getInt("status"));
//				if (rsp1.getInt("status") != 0) {
//					return "FAILURE";
//				}
//				rsp = rsp1;
//			}
//
//			JSONObject receipt = rsp.getJSONObject("receipt");
//			// String item_id = receipt.getString("item_id");
//			String product_id = receipt.getString("product_id");
//			String transaction_id = receipt.getString("transaction_id");
//
//			int rechargeId = json.getInt("rechargeId");
//			int serverId = json.getInt("serverId");
//			long roleId = json.getInt("playerId");
//			String orderId = json.getString("orderId");
//
//			PayInfo payInfo = new PayInfo();
//			payInfo.platNo = getPlatNo();
//			payInfo.platId = json.getString("userId");
//			payInfo.orderId = transaction_id;
//			payInfo.serialId = orderId;
//			payInfo.serverId = serverId;
//			payInfo.roleId = roleId;
//
//			if (!product_id.equals(RECHARGE_MAP.get(rechargeId))) {
//				LOG.error("rechargeId abnormal!!!");
//				return "FAILURE";
//			}
//
//			int money = MONEY_MAP.get(rechargeId);
//			payInfo.amount = (int) (Float.valueOf(money) / 1);
//			int code = payToGameServer(payInfo);
//			if (code != 0) {
//				LOG.error("muzhi appstore 充值发货失败！！ " + code);
//				return "0|" + (System.currentTimeMillis() / 1000);
//			}
//
//			return "1|" + (System.currentTimeMillis() / 1000);
        } catch (Exception e) {
            LOG.error("muzhi appstore 充值异常！！ ");
            e.printStackTrace();
            return "0|" + (System.currentTimeMillis() / 1000);
        }
    }

    private boolean verifyAccount(String userId, String usename, String sign) {
        LOG.error("mztkwz appStore 开始调用sidInfo接口");
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
        // String sid = "1842142_wtwl2008_1bae3148ab7305f8e2a01df924221474";
        // String[] param = sid.split("_");
        // String signSource = param[1] + "zty_267";
        //
        // try {
        // signSource = URLEncoder.encode(signSource, "utf-8");
        // } catch (UnsupportedEncodingException e) {
        // e.printStackTrace();
        // }
        // String signGenerate = Rsa.getMD5(signSource).toLowerCase();
        //
        // LOG.error("[签名原文]" + signSource);
        // LOG.error("[签名结果]" + signGenerate);
        // LOG.error("[签名传入]" + param[2]);
        String ppp = "mztkwz_appstore&%7B%22receipt-data%22%3A%22ewoJInNpZ25hdHVyZSIgPSAiQTJxN1YzWm9hNDRTeitIRllmOTRiZzFSUFI1ak9vOTNwM2lvbDBuUnpDY3dZTUJXeWZZa3I2SzlUZ2xVUVo5dmtCaGlhTHBMQTcyL0M1WEpZM2NQejdHdlJHaHdNdnhzQXJuVytFYjZ4T3cwcjhPWXFPUEZnVHJ5ZEtWTUR2NFVSYUNhMzBNQTJLM0pGU2lSK2N1Zjk4WkpMWm5PSWZFN0FaSVVVY3NBRlp3bkZsMC9EZUR2R1pDZmNrMHV1dWR6ZFRYNGRLNDZIcHVscXJoWW1OMnFGM1VxK1crRHVpY1F0S01GRXU0K2xqYU1kaXJiRUdvUENtVkdzRmRybjFCN01xQ2kvbmNNUXBRa3BpYVNyM0xDMHpVMTQ0MWlmdzlESkYrRHZQSFhoWnRSS2FqTTgwVHFvSmZLTndneW81TjlQYkY2WnJEeEQ2dlNYMWRCOTcxWEo2OEFBQVdBTUlJRmZEQ0NCR1NnQXdJQkFnSUlEdXRYaCtlZUNZMHdEUVlKS29aSWh2Y05BUUVGQlFBd2daWXhDekFKQmdOVkJBWVRBbFZUTVJNd0VRWURWUVFLREFwQmNIQnNaU0JKYm1NdU1Td3dLZ1lEVlFRTERDTkJjSEJzWlNCWGIzSnNaSGRwWkdVZ1JHVjJaV3h2Y0dWeUlGSmxiR0YwYVc5dWN6RkVNRUlHQTFVRUF3dzdRWEJ3YkdVZ1YyOXliR1IzYVdSbElFUmxkbVZzYjNCbGNpQlNaV3hoZEdsdmJuTWdRMlZ5ZEdsbWFXTmhkR2x2YmlCQmRYUm9iM0pwZEhrd0hoY05NVFV4TVRFek1ESXhOVEE1V2hjTk1qTXdNakEzTWpFME9EUTNXakNCaVRFM01EVUdBMVVFQXd3dVRXRmpJRUZ3Y0NCVGRHOXlaU0JoYm1RZ2FWUjFibVZ6SUZOMGIzSmxJRkpsWTJWcGNIUWdVMmxuYm1sdVp6RXNNQ29HQTFVRUN3d2pRWEJ3YkdVZ1YyOXliR1IzYVdSbElFUmxkbVZzYjNCbGNpQlNaV3hoZEdsdmJuTXhFekFSQmdOVkJBb01Da0Z3Y0d4bElFbHVZeTR4Q3pBSkJnTlZCQVlUQWxWVE1JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBcGMrQi9TV2lnVnZXaCswajJqTWNqdUlqd0tYRUpzczl4cC9zU2cxVmh2K2tBdGVYeWpsVWJYMS9zbFFZbmNRc1VuR09aSHVDem9tNlNkWUk1YlNJY2M4L1cwWXV4c1FkdUFPcFdLSUVQaUY0MWR1MzBJNFNqWU5NV3lwb041UEM4cjBleE5LaERFcFlVcXNTNCszZEg1Z1ZrRFV0d3N3U3lvMUlnZmRZZUZScjZJd3hOaDlLQmd4SFZQTTNrTGl5a29sOVg2U0ZTdUhBbk9DNnBMdUNsMlAwSzVQQi9UNXZ5c0gxUEttUFVockFKUXAyRHQ3K21mNy93bXYxVzE2c2MxRkpDRmFKekVPUXpJNkJBdENnbDdaY3NhRnBhWWVRRUdnbUpqbTRIUkJ6c0FwZHhYUFEzM1k3MkMzWmlCN2o3QWZQNG83UTAvb21WWUh2NGdOSkl3SURBUUFCbzRJQjF6Q0NBZE13UHdZSUt3WUJCUVVIQVFFRU16QXhNQzhHQ0NzR0FRVUZCekFCaGlOb2RIUndPaTh2YjJOemNDNWhjSEJzWlM1amIyMHZiMk56Y0RBekxYZDNaSEl3TkRBZEJnTlZIUTRFRmdRVWthU2MvTVIydDUrZ2l2Uk45WTgyWGUwckJJVXdEQVlEVlIwVEFRSC9CQUl3QURBZkJnTlZIU01FR0RBV2dCU0lKeGNKcWJZWVlJdnM2N3IyUjFuRlVsU2p0ekNDQVI0R0ExVWRJQVNDQVJVd2dnRVJNSUlCRFFZS0tvWklodmRqWkFVR0FUQ0IvakNCd3dZSUt3WUJCUVVIQWdJd2diWU1nYk5TWld4cFlXNWpaU0J2YmlCMGFHbHpJR05sY25ScFptbGpZWFJsSUdKNUlHRnVlU0J3WVhKMGVTQmhjM04xYldWeklHRmpZMlZ3ZEdGdVkyVWdiMllnZEdobElIUm9aVzRnWVhCd2JHbGpZV0pzWlNCemRHRnVaR0Z5WkNCMFpYSnRjeUJoYm1RZ1kyOXVaR2wwYVc5dWN5QnZaaUIxYzJVc0lHTmxjblJwWm1sallYUmxJSEJ2YkdsamVTQmhibVFnWTJWeWRHbG1hV05oZEdsdmJpQndjbUZqZEdsalpTQnpkR0YwWlcxbGJuUnpMakEyQmdnckJnRUZCUWNDQVJZcWFIUjBjRG92TDNkM2R5NWhjSEJzWlM1amIyMHZZMlZ5ZEdsbWFXTmhkR1ZoZFhSb2IzSnBkSGt2TUE0R0ExVWREd0VCL3dRRUF3SUhnREFRQmdvcWhraUc5Mk5rQmdzQkJBSUZBREFOQmdrcWhraUc5dzBCQVFVRkFBT0NBUUVBRGFZYjB5NDk0MXNyQjI1Q2xtelQ2SXhETUlKZjRGelJqYjY5RDcwYS9DV1MyNHlGdzRCWjMrUGkxeTRGRkt3TjI3YTQvdncxTG56THJSZHJqbjhmNUhlNXNXZVZ0Qk5lcGhtR2R2aGFJSlhuWTR3UGMvem83Y1lmcnBuNFpVaGNvT0FvT3NBUU55MjVvQVE1SDNPNXlBWDk4dDUvR2lvcWJpc0IvS0FnWE5ucmZTZW1NL2oxbU9DK1JOdXhUR2Y4YmdwUHllSUdxTktYODZlT2ExR2lXb1IxWmRFV0JHTGp3Vi8xQ0tuUGFObVNBTW5CakxQNGpRQmt1bGhnd0h5dmozWEthYmxiS3RZZGFHNllRdlZNcHpjWm04dzdISG9aUS9PamJiOUlZQVlNTnBJcjdONFl0UkhhTFNQUWp2eWdhWndYRzU2QWV6bEhSVEJoTDhjVHFBPT0iOwoJInB1cmNoYXNlLWluZm8iID0gImV3b0pJbTl5YVdkcGJtRnNMWEIxY21Ob1lYTmxMV1JoZEdVdGNITjBJaUE5SUNJeU1ERTJMVEExTFRJeklEQXdPakV3T2pJM0lFRnRaWEpwWTJFdlRHOXpYMEZ1WjJWc1pYTWlPd29KSW5WdWFYRjFaUzFwWkdWdWRHbG1hV1Z5SWlBOUlDSTBPRGd5WldFNFlqaGtPRE00WWpoak1EUTFPVEV5WXpFM1ptWTRPR1UwWVRWbE0yRTRNRE5rSWpzS0NTSnZjbWxuYVc1aGJDMTBjbUZ1YzJGamRHbHZiaTFwWkNJZ1BTQWlNVEF3TURBd01ESXhNamczTlRVeE15STdDZ2tpWW5aeWN5SWdQU0FpTVNJN0Nna2lkSEpoYm5OaFkzUnBiMjR0YVdRaUlEMGdJakV3TURBd01EQXlNVEk0TnpVMU1UTWlPd29KSW5GMVlXNTBhWFI1SWlBOUlDSXhJanNLQ1NKdmNtbG5hVzVoYkMxd2RYSmphR0Z6WlMxa1lYUmxMVzF6SWlBOUlDSXhORFl6T1RnM05ESTNNRGczSWpzS0NTSjFibWx4ZFdVdGRtVnVaRzl5TFdsa1pXNTBhV1pwWlhJaUlEMGdJamt4UWpKRU1ESTFMVGszTlVFdE5EazVReTA0TTBVM0xUQXlOa013TlRCRVJVWkVRaUk3Q2draWNISnZaSFZqZEMxcFpDSWdQU0FpWTI5dExrcHlkWFJsWTJndVZHRnVheTVRY205a2RXTXdNUzV1WlhjeElqc0tDU0pwZEdWdExXbGtJaUE5SUNJeE1URXpPVEU1TlRBMklqc0tDU0ppYVdRaUlEMGdJbU52YlM1NmRERXVWR0Z1YXlJN0Nna2ljSFZ5WTJoaGMyVXRaR0YwWlMxdGN5SWdQU0FpTVRRMk16azROelF5TnpBNE55STdDZ2tpY0hWeVkyaGhjMlV0WkdGMFpTSWdQU0FpTWpBeE5pMHdOUzB5TXlBd056b3hNRG95TnlCRmRHTXZSMDFVSWpzS0NTSndkWEpqYUdGelpTMWtZWFJsTFhCemRDSWdQU0FpTWpBeE5pMHdOUzB5TXlBd01Eb3hNRG95TnlCQmJXVnlhV05oTDB4dmMxOUJibWRsYkdWeklqc0tDU0p2Y21sbmFXNWhiQzF3ZFhKamFHRnpaUzFrWVhSbElpQTlJQ0l5TURFMkxUQTFMVEl6SURBM09qRXdPakkzSUVWMFl5OUhUVlFpT3dwOSI7CgkiZW52aXJvbm1lbnQiID0gIlNhbmRib3giOwoJInBvZCIgPSAiMTAwIjsKCSJzaWduaW5nLXN0YXR1cyIgPSAiMCI7Cn0=%22%2C+%22serverId%22%3A%221%22%2C+%22playerId%22%3A%221403067%22%2C+%22orderId%22%3A%22hjdsvjbjak%22%2C+%22userId%22%3A%22927ac14bfd8f444aaf9070b93f7b374e%22%2C+%22rechargeId%22%3A%221%22%7D";
        try {
            String content = URLDecoder.decode(ppp, "UTF-8");
//			content = content.substring(content.indexOf("{"), content.lastIndexOf("}") + 1);

            // JSONObject param = JSONObject.fromObject(content);
            // ;
            // String ss =
            // "ewoJInNpZ25hdHVyZSIgPSAiQXBwTkIwM204QnB5dENQKzliQThBNE80ZmhkN3ZJeUNqQTJ3SU5wa2xqZmpSTTBvR2U0SjFMc3FoYTFzRXJCV1BIcno4UzNibm5sNWozK2xzRHdnV2tJZW5LRHI3WWZ5UkpTbmE0RVcrZW0vSVVQazZWb2ZJRHA1SmFyV0N0TjVnYjdRVGJyanREZG9Oc3g3TGl4SkNiR3hGM1F5Qjh1cVp2enRNc01hWFBtTUFBQURWekNDQTFNd2dnSTdvQU1DQVFJQ0NCdXA0K1BBaG0vTE1BMEdDU3FHU0liM0RRRUJCUVVBTUg4eEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUtEQXBCY0hCc1pTQkpibU11TVNZd0pBWURWUVFMREIxQmNIQnNaU0JEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURXpNREVHQTFVRUF3d3FRWEJ3YkdVZ2FWUjFibVZ6SUZOMGIzSmxJRU5sY25ScFptbGpZWFJwYjI0Z1FYVjBhRzl5YVhSNU1CNFhEVEUwTURZd056QXdNREl5TVZvWERURTJNRFV4T0RFNE16RXpNRm93WkRFak1DRUdBMVVFQXd3YVVIVnlZMmhoYzJWU1pXTmxhWEIwUTJWeWRHbG1hV05oZEdVeEd6QVpCZ05WQkFzTUVrRndjR3hsSUdsVWRXNWxjeUJUZEc5eVpURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVMTUFrR0ExVUVCaE1DVlZNd2daOHdEUVlKS29aSWh2Y05BUUVCQlFBRGdZMEFNSUdKQW9HQkFNbVRFdUxnamltTHdSSnh5MW9FZjBlc1VORFZFSWU2d0Rzbm5hbDE0aE5CdDF2MTk1WDZuOTNZTzdnaTNvclBTdXg5RDU1NFNrTXArU2F5Zzg0bFRjMzYyVXRtWUxwV25iMzRucXlHeDlLQlZUeTVPR1Y0bGpFMU93QytvVG5STStRTFJDbWVOeE1iUFpoUzQ3VCtlWnRERWhWQjl1c2szK0pNMkNvZ2Z3bzdBZ01CQUFHamNqQndNQjBHQTFVZERnUVdCQlNKYUVlTnVxOURmNlpmTjY4RmUrSTJ1MjJzc0RBTUJnTlZIUk1CQWY4RUFqQUFNQjhHQTFVZEl3UVlNQmFBRkRZZDZPS2RndElCR0xVeWF3N1hRd3VSV0VNNk1BNEdBMVVkRHdFQi93UUVBd0lIZ0RBUUJnb3Foa2lHOTJOa0JnVUJCQUlGQURBTkJna3Foa2lHOXcwQkFRVUZBQU9DQVFFQWVhSlYyVTUxcnhmY3FBQWU1QzIvZkVXOEtVbDRpTzRsTXV0YTdONlh6UDFwWkl6MU5ra0N0SUl3ZXlOajVVUllISytIalJLU1U5UkxndU5sMG5rZnhxT2JpTWNrd1J1ZEtTcTY5Tkluclp5Q0Q2NlI0Szc3bmI5bE1UQUJTU1lsc0t0OG9OdGxoZ1IvMWtqU1NSUWNIa3RzRGNTaVFHS01ka1NscDRBeVhmN3ZuSFBCZTR5Q3dZVjJQcFNOMDRrYm9pSjNwQmx4c0d3Vi9abEwyNk0ydWVZSEtZQ3VYaGRxRnd4VmdtNTJoM29lSk9PdC92WTRFY1FxN2VxSG02bTAzWjliN1BSellNMktHWEhEbU9Nazd2RHBlTVZsTERQU0dZejErVTNzRHhKemViU3BiYUptVDdpbXpVS2ZnZ0VZN3h4ZjRjemZIMHlqNXdOelNHVE92UT09IjsKCSJwdXJjaGFzZS1pbmZvIiA9ICJld29KSW05eWFXZHBibUZzTFhCMWNtTm9ZWE5sTFdSaGRHVXRjSE4wSWlBOUlDSXlNREUyTFRBMExUSXdJREF6T2pNME9qQTFJRUZ0WlhKcFkyRXZURzl6WDBGdVoyVnNaWE1pT3dvSkluVnVhWEYxWlMxcFpHVnVkR2xtYVdWeUlpQTlJQ0kwT0RneVpXRTRZamhrT0RNNFlqaGpNRFExT1RFeVl6RTNabVk0T0dVMFlUVmxNMkU0TUROa0lqc0tDU0p2Y21sbmFXNWhiQzEwY21GdWMyRmpkR2x2YmkxcFpDSWdQU0FpTVRBd01EQXdNREl3TmprMU1qY3lOaUk3Q2draVluWnljeUlnUFNBaU1TSTdDZ2tpZEhKaGJuTmhZM1JwYjI0dGFXUWlJRDBnSWpFd01EQXdNREF5TURZNU5USTNNallpT3dvSkluRjFZVzUwYVhSNUlpQTlJQ0l4SWpzS0NTSnZjbWxuYVc1aGJDMXdkWEpqYUdGelpTMWtZWFJsTFcxeklpQTlJQ0l4TkRZeE1UUTRORFExTkRVNElqc0tDU0oxYm1seGRXVXRkbVZ1Wkc5eUxXbGtaVzUwYVdacFpYSWlJRDBnSWpBek5VUTBRall5TFVReVJFVXROREExTnkwNVFrRTRMVUZGTmtFNVFUZzROVFEwT1NJN0Nna2ljSEp2WkhWamRDMXBaQ0lnUFNBaVkyOXRMbTExZW1ocExuUmhibXMyTUNJN0Nna2lhWFJsYlMxcFpDSWdQU0FpTVRFd05UYzBOVEkwTnlJN0Nna2lZbWxrSWlBOUlDSmpiMjB1YlhWNmFHa3VkR0Z1YXlJN0Nna2ljSFZ5WTJoaGMyVXRaR0YwWlMxdGN5SWdQU0FpTVRRMk1URTBPRFEwTlRRMU9DSTdDZ2tpY0hWeVkyaGhjMlV0WkdGMFpTSWdQU0FpTWpBeE5pMHdOQzB5TUNBeE1Eb3pORG93TlNCRmRHTXZSMDFVSWpzS0NTSndkWEpqYUdGelpTMWtZWFJsTFhCemRDSWdQU0FpTWpBeE5pMHdOQzB5TUNBd016b3pORG93TlNCQmJXVnlhV05oTDB4dmMxOUJibWRsYkdWeklqc0tDU0p2Y21sbmFXNWhiQzF3ZFhKamFHRnpaUzFrWVhSbElpQTlJQ0l5TURFMkxUQTBMVEl3SURFd09qTTBPakExSUVWMFl5OUhUVlFpT3dwOSI7CgkiZW52aXJvbm1lbnQiID0gIlNhbmRib3giOwoJInBvZCIgPSAiMTAwIjsKCSJzaWduaW5nLXN0YXR1cyIgPSAiMCI7Cn0=";
            // String ss =
            // "ewoJInNpZ25hdHVyZSIgPSAiQWh3YWYrTlJNTW1VdThhUGR6SW9QbXFMZTBXWjh2LzN4MUFiOG1zbnR5bnVSWkFVNU1PcmdrclJFbXlRekh5WGNicTc5YmNwcHNHcFBVMzdkd1NyWlhlYU9PV0llcU9CRmNaaWFCZlozMWxlbkZZdTZqTUFNbkM4bWlCSnJRWmxSS01rRm5zUldnc2RCUk0xLy9qN0dRWGxheTZuN2ljcFRIeHV2WVB1M1VVV0FBQURWekNDQTFNd2dnSTdvQU1DQVFJQ0NCdXA0K1BBaG0vTE1BMEdDU3FHU0liM0RRRUJCUVVBTUg4eEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUtEQXBCY0hCc1pTQkpibU11TVNZd0pBWURWUVFMREIxQmNIQnNaU0JEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURXpNREVHQTFVRUF3d3FRWEJ3YkdVZ2FWUjFibVZ6SUZOMGIzSmxJRU5sY25ScFptbGpZWFJwYjI0Z1FYVjBhRzl5YVhSNU1CNFhEVEUwTURZd056QXdNREl5TVZvWERURTJNRFV4T0RFNE16RXpNRm93WkRFak1DRUdBMVVFQXd3YVVIVnlZMmhoYzJWU1pXTmxhWEIwUTJWeWRHbG1hV05oZEdVeEd6QVpCZ05WQkFzTUVrRndjR3hsSUdsVWRXNWxjeUJUZEc5eVpURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVMTUFrR0ExVUVCaE1DVlZNd2daOHdEUVlKS29aSWh2Y05BUUVCQlFBRGdZMEFNSUdKQW9HQkFNbVRFdUxnamltTHdSSnh5MW9FZjBlc1VORFZFSWU2d0Rzbm5hbDE0aE5CdDF2MTk1WDZuOTNZTzdnaTNvclBTdXg5RDU1NFNrTXArU2F5Zzg0bFRjMzYyVXRtWUxwV25iMzRucXlHeDlLQlZUeTVPR1Y0bGpFMU93QytvVG5STStRTFJDbWVOeE1iUFpoUzQ3VCtlWnRERWhWQjl1c2szK0pNMkNvZ2Z3bzdBZ01CQUFHamNqQndNQjBHQTFVZERnUVdCQlNKYUVlTnVxOURmNlpmTjY4RmUrSTJ1MjJzc0RBTUJnTlZIUk1CQWY4RUFqQUFNQjhHQTFVZEl3UVlNQmFBRkRZZDZPS2RndElCR0xVeWF3N1hRd3VSV0VNNk1BNEdBMVVkRHdFQi93UUVBd0lIZ0RBUUJnb3Foa2lHOTJOa0JnVUJCQUlGQURBTkJna3Foa2lHOXcwQkFRVUZBQU9DQVFFQWVhSlYyVTUxcnhmY3FBQWU1QzIvZkVXOEtVbDRpTzRsTXV0YTdONlh6UDFwWkl6MU5ra0N0SUl3ZXlOajVVUllISytIalJLU1U5UkxndU5sMG5rZnhxT2JpTWNrd1J1ZEtTcTY5Tkluclp5Q0Q2NlI0Szc3bmI5bE1UQUJTU1lsc0t0OG9OdGxoZ1IvMWtqU1NSUWNIa3RzRGNTaVFHS01ka1NscDRBeVhmN3ZuSFBCZTR5Q3dZVjJQcFNOMDRrYm9pSjNwQmx4c0d3Vi9abEwyNk0ydWVZSEtZQ3VYaGRxRnd4VmdtNTJoM29lSk9PdC92WTRFY1FxN2VxSG02bTAzWjliN1BSellNMktHWEhEbU9Nazd2RHBlTVZsTERQU0dZejErVTNzRHhKemViU3BiYUptVDdpbXpVS2ZnZ0VZN3h4ZjRjemZIMHlqNXdOelNHVE92UT09IjsKCSJwdXJjaGFzZS1pbmZvIiA9ICJld29KSW05eWFXZHBibUZzTFhCMWNtTm9ZWE5sTFdSaGRHVXRjSE4wSWlBOUlDSXlNREUyTFRBMExUSXdJREF5T2pRM09qVXpJRUZ0WlhKcFkyRXZURzl6WDBGdVoyVnNaWE1pT3dvSkluVnVhWEYxWlMxcFpHVnVkR2xtYVdWeUlpQTlJQ0kwT0RneVpXRTRZamhrT0RNNFlqaGpNRFExT1RFeVl6RTNabVk0T0dVMFlUVmxNMkU0TUROa0lqc0tDU0p2Y21sbmFXNWhiQzEwY21GdWMyRmpkR2x2YmkxcFpDSWdQU0FpTVRBd01EQXdNREl3TmprME1EazNNQ0k3Q2draVluWnljeUlnUFNBaU1TSTdDZ2tpZEhKaGJuTmhZM1JwYjI0dGFXUWlJRDBnSWpFd01EQXdNREF5TURZNU5EQTVOekFpT3dvSkluRjFZVzUwYVhSNUlpQTlJQ0l4SWpzS0NTSnZjbWxuYVc1aGJDMXdkWEpqYUdGelpTMWtZWFJsTFcxeklpQTlJQ0l4TkRZeE1UUTFOamN6TkRJeUlqc0tDU0oxYm1seGRXVXRkbVZ1Wkc5eUxXbGtaVzUwYVdacFpYSWlJRDBnSWpBek5VUTBRall5TFVReVJFVXROREExTnkwNVFrRTRMVUZGTmtFNVFUZzROVFEwT1NJN0Nna2ljSEp2WkhWamRDMXBaQ0lnUFNBaVkyOXRMbTExZW1ocExuUmhibXMyTUNJN0Nna2lhWFJsYlMxcFpDSWdQU0FpTVRFd05UYzBOVEkwTnlJN0Nna2lZbWxrSWlBOUlDSmpiMjB1YlhWNmFHa3VkR0Z1YXlJN0Nna2ljSFZ5WTJoaGMyVXRaR0YwWlMxdGN5SWdQU0FpTVRRMk1URTBOVFkzTXpReU1pSTdDZ2tpY0hWeVkyaGhjMlV0WkdGMFpTSWdQU0FpTWpBeE5pMHdOQzB5TUNBd09UbzBOem8xTXlCRmRHTXZSMDFVSWpzS0NTSndkWEpqYUdGelpTMWtZWFJsTFhCemRDSWdQU0FpTWpBeE5pMHdOQzB5TUNBd01qbzBOem8xTXlCQmJXVnlhV05oTDB4dmMxOUJibWRsYkdWeklqc0tDU0p2Y21sbmFXNWhiQzF3ZFhKamFHRnpaUzFrWVhSbElpQTlJQ0l5TURFMkxUQTBMVEl3SURBNU9qUTNPalV6SUVWMFl5OUhUVlFpT3dwOSI7CgkiZW52aXJvbm1lbnQiID0gIlNhbmRib3giOwoJInBvZCIgPSAiMTAwIjsKCSJzaWduaW5nLXN0YXR1cyIgPSAiMCI7Cn0=";
            //LOG.error(content);
            //
            // JSONObject params = new JSONObject();
            // // params.put("receipt-data", param.get("receipt-data"));
            // params.put("receipt-data", ss);
            // String body = params.toString();
            // LOG.error("[请求参数]" + body);
            //
            // String result =
            // HttpUtils.sentPost("https://sandbox.itunes.apple.com/verifyReceipt",
            // body);
            // LOG.error("[appstore 返回]" + result);

        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

}
