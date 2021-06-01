package com.account.plat.impl.oppo;

import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.spec.X509EncodedKeySpec;
import java.util.Date;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PlatBase;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import com.nearme.oauth.model.AccessToken;
import com.nearme.oauth.open.AccountAgent;

class OppoAccount {
    public String id;
    public String userName;
}

@Component
public class OppoPlat extends PlatBase {
    // sdk server的接口地址
    // private static String serverUrl = "";
    //
    // // 游戏编号
    // private static int AppID;
    //
    // // 分配给游戏合作商的接入密钥,请做好安全保密
    // private static String AppKey = "";
    //
    // private static String AppSecret = "";

    private static String PublicKey = "";

    private static String CALLBACK_OK = "OK";

    private static String CALLBACK_FAIL = "FAIL";

    private static final String RESULT_STR = "result=%s&resultMsg=%s";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/oppo/", "plat.properties");
        // AppID = Integer.valueOf(properties.getProperty("AppID"));
        // AppKey = properties.getProperty("AppKey");
        // AppSecret = properties.getProperty("AppSecret");
        PublicKey = properties.getProperty("PublicKey");
        // serverUrl = properties.getProperty("VERIRY_URL");
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
        String oauth_token_secret = vParam[1];

        OppoAccount oppoAccount = verifyAccount(oauth_token, oauth_token_secret);
        if (oppoAccount == null) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), oppoAccount.id);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(oppoAccount.id);
            account.setAccount(getPlatNo() + "_" + oppoAccount.id);
            account.setPasswd(oppoAccount.id);
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
        // TODO Auto-generated method stub
        if (!param.containsKey("sid") || !param.containsKey("baseVersion") || !param.containsKey("version") || !param.containsKey("deviceNo")) {
            return GameError.PARAM_ERROR;
        }

        String sid = param.getString("sid");
        String baseVersion = param.getString("baseVersion");
        String versionNo = param.getString("version");
        String deviceNo = param.getString("deviceNo");

        String[] vParam = sid.split("&");
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String oauth_token = vParam[0].split("=")[1];
        String oauth_token_secret = vParam[1].split("=")[1];

        OppoAccount oppoAccount = verifyAccount(oauth_token, oauth_token_secret);
        if (oppoAccount == null) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), oppoAccount.id);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(oppoAccount.id);
            account.setAccount(getPlatNo() + "_" + oppoAccount.id);
            account.setPasswd(oppoAccount.id);
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
            account.setVersionNo(versionNo);
            account.setDeviceNo(deviceNo);
            account.setLoginDate(new Date());
            accountDao.updateTokenAndVersion(account);
        }

        GameError authorityRs = super.checkAuthority(account);
        if (authorityRs != GameError.OK) {
            return authorityRs;
        }

        response.put("recent", super.getRecentServers(account));
        response.put("keyId", account.getKeyId());
        response.put("token", account.getToken());

        if (isActive(account)) {
            response.put("active", 1);
        } else {
            response.put("active", 0);
        }

        return GameError.OK;
    }

    // private JSONObject packResponse(int ResultCode) {
    // // MD5(AppID+ResultCode+SecretKey)
    // String signSource = AppID + String.valueOf(ResultCode) + SecretKey;
    // String Sign = MD5.md5Digest(signSource);
    //
    // JSONObject res = new JSONObject();
    // res.put("AppID", AppID);
    // res.put("ResultCode", ResultCode);
    // res.put("ResultMsg", "");
    // res.put("Sign", Sign);
    // return res;
    // }

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
            // TODO: handle exception
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay oppo");

        try {
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

//			Long lordId = Long.valueOf(infos[0]);
//			int serverid = Integer.valueOf(infos[1]);
//			int rechargeId = Integer.valueOf(infos[2]);
//			String exorderno = infos[3];

//			int rsCode = payResult(lordId, serverid, Double.valueOf(price) * Integer.valueOf(count), rechargeId, notifyId, exorderno);
            int rsCode = 0;
            if (rsCode == 200) {
                LOG.error("返回充值成功");
                return String.format(RESULT_STR, CALLBACK_OK, "sucess");
            } else {
                LOG.error("返回充值失败");
                return String.format(RESULT_STR, CALLBACK_FAIL, "failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            LOG.error("支付异常 ");
            return String.format(RESULT_STR, CALLBACK_FAIL, "failed");
        }
    }

    private OppoAccount verifyAccount(String token, String secret) {
        LOG.error("oppo开始调用sidInfo接口");
        try {
            String gcUserInfo = AccountAgent.getInstance().getGCUserInfo(new AccessToken(token, secret));
            LOG.error("oppo 登陆信息:" + gcUserInfo);
            JSONObject data = JSONObject.fromObject(gcUserInfo);
            JSONObject user = data.getJSONObject("BriefUser");
            String id = user.getString("id");
            String userName = user.getString("userName");

            OppoAccount oppoAccount = new OppoAccount();
            oppoAccount.id = id;
            oppoAccount.userName = userName;
            return oppoAccount;
        } catch (Exception e) {
            // TODO: handle exception
            e.printStackTrace();
            return null;
        }
    }
}
