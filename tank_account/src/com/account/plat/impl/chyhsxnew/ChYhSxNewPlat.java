package com.account.plat.impl.chyhsxnew;

import java.net.URLDecoder;
import java.nio.charset.Charset;
import java.util.Arrays;
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
import com.account.plat.impl.chYhSx.util.SignHelper;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.test.Rsa;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class ChYhSxNewPlat extends PlatBase {
    // sdk server的接口地址
    // private static String VERIRY_URL = "";
    private static String APP_ID;
    // private static String APP_KEY;
    // private static String APP_SECRET = "";
    /**
     * 下单地址
     */
    private static String order_url;

    /**
     * RSA加密私钥
     */
    private static String private_key;

    /**
     * RSA解密公钥
     */
    private static String public_key;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chYhSx/",
                "plat.properties");

        order_url = properties.getProperty("order_url");
        APP_ID = properties.getProperty("APP_ID");
        public_key = properties.getProperty("public_key");
        private_key = properties.getProperty("private_key");

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

        // String userId = verifyAccount(sid);
        String userId = sid;
        if (userId == null) {
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

    private JSONObject getParamsStr(Map<String, String> params) {
        JSONObject json = new JSONObject();
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("sign") || k.equals("plat")) {
                continue;
            }

            if (params.get(k) == null || params.get(k).equals("")) {
                continue;
            }

            json.put(k, (String) params.get(k));
        }
        return json;
    }

    public static Map<String, String> getParmters(String respData) {
        Map<String, String> map = new HashMap<>();
        String params[] = respData.split("&");

        for (int i = 0; i < respData.length(); i++) {
            String date[] = params[i].split("=");
            map.put(date[0], date[1]);
        }
        return map;
    }

    @Override
    public String order(WebRequest request, String content) {
        LOG.error("chYhSx 创建订单");
        Map<String, String> params = new HashMap<String, String>();
        try {
            params.put("appid", request.getParameter("appid"));
            params.put("waresid", request.getParameter("waresid"));
            params.put("waresname", request.getParameter("waresname"));
            params.put("cporderid", request.getParameter("cporderid"));
            params.put("price", request.getParameter("price"));
            params.put("currency", request.getParameter("currency"));
            params.put("appuserid", request.getParameter("appuserid"));
            params.put("cpprivateinfo", request.getParameter("cpprivateinfo"));
            params.put("notifyurl", request.getParameter("notifyurl"));

            String transdata = getParamsStr(params).toString();
            String sign = Rsa.sign(transdata, private_key);
            String paramsSrt = "transdata=" + transdata + "&sign=" + sign
                    + "&signtype=RSA";
            LOG.error("下单请求参数=" + paramsSrt);
            String result = HttpUtils.sentPost(order_url, paramsSrt);
            LOG.error("下单接受到的参数=" + result);

            params.clear();
            params = getParmters(result);
            JSONObject repJson = JSONObject.fromObject(params.get("transdata"));
            if (repJson.has("code")) {
                return "fail";
            }
            if (repJson.has("transid")) {
                return repJson.getString("transid");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "fail";
    }

    @Override
    public String payBack(WebRequest request, String content,
                          HttpServletResponse response) {
        LOG.error("pay chYhSx");
        LOG.error("[接收到的参数]" + content);

        try {

            String transdata = URLDecoder.decode(request.getParameter("transdata"), "UTF-8");
            LOG.error("transdata=" + transdata);
            String sign = request.getParameter("sign");
            LOG.error("sign=" + sign);

            // 签名
            // String checkSign = SignHelper.sign(content, private_key);

            LOG.error("public_key:" + public_key);


            // 验签
            if (!SignHelper.verify(transdata, sign, public_key)) {
                // 验证失败
                LOG.error("支付RSA验签失败");
                return "fail";
            }
            // if (!Rsa.doCheck(transdata, sign, public_key)){
            // // 验证失败
            // LOG.error("支付RSA验签失败");
            // return "fail";
            // }
            // 解析 transdata json 类型
            JSONObject json = JSONObject.fromObject(transdata);
            String transid = json.getString("transid");
//
//			boolean isValid = RSASignature.doCheck(transdata, sign, public_key,
//					"UTF-8");
//			if (isValid == false) {
//				LOG.error("签名不一致");
//			}

            String result = json.getString("result");
            String cpprivate = json.getString("cpprivate");
            String money = json.getString("money");
            if (result == null || !result.equals("0")) {
                LOG.error("支付结果失败");
                return "SUCCESS";
            }

            String[] infos = cpprivate.split("_");
            if (infos.length != 3) {
                LOG.error("自有参数有问题");
                return "SUCCESS";
            }

            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = json.getString("appuserid");
            payInfo.orderId = transid;
            payInfo.serialId = cpprivate;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(money);
            payInfo.amount = (int) payInfo.realAmount;
            int code = payToGameServer(payInfo);
            if (code == 0) {
                LOG.error("chYhSx 返回充值成功");
            } else {
                LOG.error("chYhSx 返回充值失败");
            }
            return "SUCCESS";

        } catch (Exception e) {
            // TODO: handle exception
        }
        return "SUCCESS";
    }

    private String verifyAccount(String logintoken) {
        LOG.error("chYhSx 开始调用sidInfo接口");

        try {
            Map<String, String> params = new HashMap<String, String>();
            params.put("appid", APP_ID);
            params.put("logintoken", logintoken);

            String transdata = getParamsStr(params).toString();
            String sign = Rsa.sign(transdata, private_key);
            String paramsSrt = "transdata=" + transdata + "&sign=" + sign
                    + "&signtype=RSA";
            LOG.error("登陆请求参数=" + paramsSrt);
            String result = HttpUtils.sentPost(order_url, paramsSrt);
            LOG.error("登陆接受到的参数=" + result);

            params.clear();
            params = getParmters(transdata);
            JSONObject repJson = JSONObject.fromObject(params.get("transdata"));
            if (repJson.has("code")) {
                return null;
            }
            if (repJson.has("userid")) {
                return repJson.getString("userid");
            }
            return null;
        } catch (Exception e) {
            LOG.error("接口返回异常");
            e.printStackTrace();
            return null;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }

    }

    /**
     * 应用私钥：
     * 用于对商户应用发送到平台的数据进行加密
     */
    public final static String APPV_KEY = "MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAL4R01LLgIGt7shD2TWff2xjTsZbgmzAIFycBxQQhusqlKqcgUP9pzkJdm3pX4DlN2vRYclExvrusECtmEWoN3+J6Iu6t5hop4dSEuOiVaDH0+s5qdegGvS4YipxxDaycm3Jq7looYNYmytbQt1X44tIggxJP6RHKfdfrPAId9wpAgMBAAECgYAosUpMDJObr/BSYexMBbTTMMO5xfe7brq++Qyu6AbqrDgd+tnWA6VcmcEIMRGoV+qwo6hK3fW33YhQoJncN/KBdgbworySUBbOGY9NrD9FHY5Owa+d4zBeNFxxPE6dDjG+iqgYyJMyOVaDXU4sz9ohWWjtHskUDGvROeRfr/XFbQJBAOyTRmFwEgSBXDvKbtpRZKwhy8aJ2Sb12aOTYcCXdcM/S3Iv1GdLbj09f338yGgnw2zdE+ZhQgNH5+8UkYfFz2cCQQDNrQTNf44wKoHa58nLX+3bckIwW8qtpnnjjUW7VxgrMak9gl0VaA7Ixi+ZTNSVsaafmBRTNejetxlaMn63xQ3vAkEApWePFL8jiczcLN2rRa8UwRjb/ZMRpaDMqwZ3mQ0MhBdz64Evc40UpXKi+fZMNC5g/3NO34tueRbEPa9W1OPjzwJAVRhvs0JCJwV/Qn3CDOX8uF2WqwFfYudM6OvrXO5U7pIWbn+AWbn62/C7gta54dFlmgRG7IKSfYsN7zaTHR9newJAVYV5jFpstctt+0smlKbKHFdThn+U9b1gBMYB7mZz69TTzbYeMFqQo8hg9+7VsiWGYWrXJIUf11zpm08xDr20sQ==";

    /**
     * 平台公钥：
     * 用于商户应用对接收平台的数据进行解密
     */
    public final static String PLATP_KEY = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCEHF9KHHO5u1KXMkeFYUkZFI4j8Qm21pOOMnNtZ+fiWHjJcRcdi4r3+ypvCa22MlKVjVdqYHccwOY7AQE85PR9OSJeq9c3DrltP8GB05MybKMDewsUA+oRDNeVEojT4twWzHBBeymoWxijK2S+bclkxVVCoZd1WP1x3dhKlGhwswIDAQAB";

    public static void main(String[] args) {
		/*String transdata = "{\"appid\":\"5000412152\",\"appuserid\":\"17207476\",\"cporderid\":\"172_17207476_1494933521874\",\"cpprivate\":\"172_17207476_1494933521874\",\"currency\":\"RMB\",\"feetype\":0,\"money\":10.00,\"paytype\":403,\"result\":0,\"transid\":\"32061705161918422896\",\"transtime\":\"2017-05-16 19:18:58\",\"transtype\":0,\"waresid\":1}";
		String sign = "cBY/MSQpoF4ENt7wK9w9UPPH49f06XWJlUA1lvv4Y4IZaFpVqBLhpDCnNJPIibviKuYzJWDPH27IFWJYmcf137F2nrV0R+eaUtsIHuKOgDxnwijlUkU/1PDdKptATnq0ZLF+TgIXRJvO0VK3Uru7m/nvRl3DYBCG0BcUtWLiOVo=";
//		sign = "BPKegcXbyF4gvwt8X Cn6WoeHdV3qUI01q0r36DppuK QiTfwbl V/dolC1wYvihPAtI31 02ZOvA55GGW4zpWFFlg8xFKbSOFktS94hBWvsGSjmV0kFhamigAuDaohnH/9G/HIz0L6ijiVI44yEct2iGb9eIZv/vYw7kCZo9kU=";
		String PLATP_KEY = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCEHF9KHHO5u1KXMkeFYUkZFI4j8Qm21pOOMnNtZ+fiWHjJcRcdi4r3+ypvCa22MlKVjVdqYHccwOY7AQE85PR9OSJeq9c3DrltP8GB05MybKMDewsUA+oRDNeVEojT4twWzHBBeymoWxijK2S+bclkxVVCoZd1WP1x3dhKlGhwswIDAQAB";
		String APPV_KEY = "MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAL4R01LLgIGt7shD2TWff2xjTsZbgmzAIFycBxQQhusqlKqcgUP9pzkJdm3pX4DlN2vRYclExvrusECtmEWoN3+J6Iu6t5hop4dSEuOiVaDH0+s5qdegGvS4YipxxDaycm3Jq7looYNYmytbQt1X44tIggxJP6RHKfdfrPAId9wpAgMBAAECgYAosUpMDJObr/BSYexMBbTTMMO5xfe7brq++Qyu6AbqrDgd+tnWA6VcmcEIMRGoV+qwo6hK3fW33YhQoJncN/KBdgbworySUBbOGY9NrD9FHY5Owa+d4zBeNFxxPE6dDjG+iqgYyJMyOVaDXU4sz9ohWWjtHskUDGvROeRfr/XFbQJBAOyTRmFwEgSBXDvKbtpRZKwhy8aJ2Sb12aOTYcCXdcM/S3Iv1GdLbj09f338yGgnw2zdE+ZhQgNH5+8UkYfFz2cCQQDNrQTNf44wKoHa58nLX+3bckIwW8qtpnnjjUW7VxgrMak9gl0VaA7Ixi+ZTNSVsaafmBRTNejetxlaMn63xQ3vAkEApWePFL8jiczcLN2rRa8UwRjb/ZMRpaDMqwZ3mQ0MhBdz64Evc40UpXKi+fZMNC5g/3NO34tueRbEPa9W1OPjzwJAVRhvs0JCJwV/Qn3CDOX8uF2WqwFfYudM6OvrXO5U7pIWbn+AWbn62/C7gta54dFlmgRG7IKSfYsN7zaTHR9newJAVYV5jFpstctt+0smlKbKHFdThn+U9b1gBMYB7mZz69TTzbYeMFqQo8hg9+7VsiWGYWrXJIUf11zpm08xDr20sQ==";
		boolean result = SignHelper.verify(transdata, sign, PLATP_KEY);
		String checkSign = SignHelper.sign(transdata, APPV_KEY);
		LOG.error(result);
		LOG.error(checkSign);
		LOG.error(sign.equals(checkSign));
		
		String defaultCharsetName=Charset.defaultCharset().displayName();   
        LOG.error("defaultCharsetName:"+defaultCharsetName);*/
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return null;
    }
}
