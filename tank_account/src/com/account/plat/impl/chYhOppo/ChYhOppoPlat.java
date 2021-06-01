package com.account.plat.impl.chYhOppo;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.spec.X509EncodedKeySpec;
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
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class ChYhOppoPlat extends PlatBase {

    private static String PublicKey = "";

    private static String CALLBACK_OK = "OK";

    private static String CALLBACK_FAIL = "FAIL";

    private static String AppKey = "";

    private static String AppSecret = "";

    private static String serverUrl = "";

    private static final String RESULT_STR = "result=%s&resultMsg=%s";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chYhOppo/", "plat.properties");
        // AppID = Integer.valueOf(properties.getProperty("AppID"));
        AppKey = properties.getProperty("AppKey");
        AppSecret = properties.getProperty("AppSecret");
        PublicKey = properties.getProperty("PublicKey");
        serverUrl = properties.getProperty("VERIRY_URL");
    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String[] vParam = sid.split("&");
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String oauth_token = vParam[0];
        String ssoid = vParam[1];

        if (!verifyAccount(oauth_token, ssoid)) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), ssoid);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(ssoid);
            account.setAccount(getPlatNo() + "_" + ssoid);
            account.setPasswd(ssoid);
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
    public GameError doLogin(JSONObject param, JSONObject response) {
        return null;
    }

    private boolean doCheck(String content, String sign) {
        try {
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");

            byte[] encodedKey = org.apache.commons.codec.binary.Base64.decodeBase64(PublicKey);
            PublicKey pubKey = keyFactory.generatePublic(new X509EncodedKeySpec(encodedKey));

            java.security.Signature signature = java.security.Signature.getInstance("SHA1WithRSA");

            signature.initVerify(pubKey);
            signature.update(content.getBytes("UTF-8"));
            boolean bverify = signature.verify(org.apache.commons.codec.binary.Base64.decodeBase64(sign));
            return bverify;
        } catch (Exception e) {
            LOG.error("chYhOppo doCheck error");
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay chYhOppo");

        try {
            LOG.error("pay chYhOppo content:" + content);
            LOG.error("[开始参数]");
            Iterator<String> iterator = request.getParameterNames();
            Map<String, String> params = new HashMap<>();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
                params.put(paramName, URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
            }
            LOG.error("[结束参数]");

            String notifyId = request.getParameter("notifyId");
            String partnerOrder = request.getParameter("partnerOrder");
            String productName = request.getParameter("productName");
            String productDesc = request.getParameter("productDesc");
            String price = request.getParameter("price");
            String count = request.getParameter("count");
            String attach = request.getParameter("attach");
            String sign = request.getParameter("sign");

            LOG.error("sign:" + sign);
            final StringBuilder baseString = new StringBuilder();
            baseString.append("notifyId=");
            baseString.append(notifyId);
            baseString.append("&partnerOrder=");
            baseString.append(partnerOrder);
            baseString.append("&productName=");
            baseString.append(productName);
            baseString.append("&productDesc=");
            baseString.append(productDesc);
            baseString.append("&price=");
            baseString.append(price);
            baseString.append("&count=");
            baseString.append(count);
            baseString.append("&attach=");
            baseString.append(attach);
            String param = baseString.toString();
            LOG.error("[接收到的参数]" + param);
            boolean check = doCheck(param, sign);
            if (!check) {
                LOG.error("检查失败");
                return String.format(RESULT_STR, CALLBACK_FAIL, "failed");
            }

            String[] infos = attach.split("_");
            if (infos.length != 4) {
                LOG.error("传参错误");
                return String.format(RESULT_STR, CALLBACK_FAIL, "failed");
            }

            Long lordId = Long.valueOf(infos[0]);
            int serverid = Integer.valueOf(infos[1]);
            String userId = infos[3];

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = userId;
            payInfo.orderId = partnerOrder;

            payInfo.serialId = serverid + "_" + lordId + "_" + partnerOrder;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(price) / 100;
            payInfo.amount = (int) payInfo.realAmount;
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("chYhOppo 充值发货失败！！ " + code);
                return String.format(RESULT_STR, CALLBACK_FAIL, "failed");
            }
            return String.format(RESULT_STR, CALLBACK_OK, "sucess");
        } catch (Exception e) {
            e.printStackTrace();
            LOG.error("支付异常 ");
            return String.format(RESULT_STR, CALLBACK_FAIL, "failed");
        }
    }

    private boolean verifyAccount(String token, String secret) {
        LOG.error("chYhOppo开始调用sidInfo接口");
        try {
            String request_serverUrl = serverUrl + "?fileId=" + secret + "&token=" + SnsSigCheck.encodeUrl(token);
            int nonce = (int) (Math.random() * ((9999999999L - 1000000000) + 1000000000));
            int ts = (int) ((new Date()).getTime() / 1000);

            StringBuilder sb = new StringBuilder();
            sb.append("oauthConsumerKey").append("=").append(URLEncoder.encode(AppKey, "UTF-8")).append("&").append("oauthToken").append("=")
                    .append(URLEncoder.encode(token, "UTF-8")).append("&").append("oauthSignatureMethod").append("=")
                    .append(URLEncoder.encode("HMAC-SHA1", "UTF-8")).append("&").append("oauthTimestamp").append("=")
                    .append(URLEncoder.encode(String.valueOf(ts), "UTF-8")).append("&").append("oauthNonce").append("=")
                    .append(URLEncoder.encode(String.valueOf(nonce), "UTF-8")).append("&").append("oauthVersion").append("=")
                    .append(URLEncoder.encode("1.0", "UTF-8")).append("&");

            String baseStr = sb.toString();
            String sign = SnsSigCheck.generateSign(AppSecret, baseStr);

            Map<String, String> head = new HashMap<String, String>();
            head.put("param", baseStr);
            head.put("oauthSignature", sign);

            String result = HttpUtils.sentGet(request_serverUrl, "UTF-8", head);
            LOG.error("[返回结果]" + result);
            if (result == null) {
                return false;
            }
            JSONObject rets = JSONObject.fromObject(result);
            if (rets.getInt("resultCode") != 200) {
                return false;
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
