package com.account.plat.impl.chYhHw;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.*;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import com.account.util.HttpHelper;
import net.sf.json.JSON;
import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;


import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.muzhiJh.HttpUtils;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class ChYhHwPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static String APP_ID;

    private static String APP_KEY = "";

    private static String APP_SECRET = "";

    private static String LOGIN_KEY = "";

    private static String GAME_PUBLIC = "";
    private static String GAME_PRIVATE = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chYhHw/", "plat.properties");
        APP_ID = properties.getProperty("APP_ID");
        APP_KEY = properties.getProperty("APP_KEY");
        APP_SECRET = properties.getProperty("APP_SECRET");
        LOGIN_KEY = properties.getProperty("LOGIN_KEY");
        serverUrl = properties.getProperty("VERIRY_URL");

        GAME_PUBLIC = properties.getProperty("GAME_PUBLIC");
        GAME_PRIVATE = properties.getProperty("GAME_PRIVATE");
    }

    @Override
    public String order(WebRequest request, String content) {
        try {
            JSONObject result = new JSONObject();
            result.put("privateKey", APP_SECRET);
            return result.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        // TODO Auto-generated method stub
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
        LOG.error("华为草花 sid " + sid);

        String access_token = vParam[0];
        String roleId = vParam[1];

        if (vParam.length == 2) {
            if (!verifyAccount(roleId, access_token)) {
                return GameError.SDK_LOGIN;
            }
        } else if (vParam.length == 3) {
            String ts = vParam[2];
            if (!verifyAccount(roleId, ts, access_token)) {
                return GameError.SDK_LOGIN;
            }
        } else if (vParam.length == 4) {
            String ts = vParam[3];
            String playerLevel = vParam[2];
            if (!verifyAccount(ts, roleId, playerLevel, access_token, GAME_PRIVATE)) {
                return GameError.SDK_LOGIN;
            }
        } else {
            return GameError.SDK_LOGIN;
        }


        Account account = accountDao.selectByPlatId(getPlatNo(), roleId);

        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(roleId);
            account.setAccount(getPlatNo() + "_" + roleId);
            account.setPasswd(roleId);
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

    private static boolean verifyAccount(String ts, String playerId, String playerLevel, String playerSSign, String privateKey) {
        try {
            List<String> key = new ArrayList<>();
            key.add("method");
            key.add("appId");
            key.add("cpId");
            key.add("ts");
            key.add("playerId");
            key.add("playerSSign");
            key.add("playerLevel");
            Collections.sort(key);


            //LOG.error(com.alibaba.fastjson.JSON.toJSONString(key));

            Map<String, String> val = new HashMap<>();
            val.put("method", "external.hms.gs.checkPlayerSign");
            val.put("appId", APP_ID);
            val.put("cpId", "890086000001007296");
            val.put("ts", ts);
            val.put("playerId", playerId);
            val.put("playerSSign", playerSSign);
            val.put("playerLevel", playerLevel);


            StringBuilder sb = new StringBuilder();

            for (String k : key) {
                sb.append(k);
                sb.append("=");
                sb.append(val.get(k));
                sb.append("&");
            }

            String signStr = sb.substring(0, sb.length() - 1);


            String cpSign = RSAUtil.sha256WithRsa(signStr.getBytes(), privateKey);

            val.put("cpSign", URLEncoder.encode(cpSign, "utf-8"));

            //LOG.error("华为草花签名字符串signStr " + signStr);
            //LOG.error("华为草花签名值cpSign " + cpSign);
            //LOG.error("华为草花请求参数val " + com.alibaba.fastjson.JSON.toJSONString(val));
            String result = HttpHelper.doPost("https://gss-cn.game.hicloud.com/gameservice/api/gbClientApi", val);

            //LOG.error("华为草花草花华为验证结果 " + result);
            if (result == null) {
                return false;
            }

            com.alibaba.fastjson.JSONObject jsonObject = com.alibaba.fastjson.JSONObject.parseObject(result);

            if (jsonObject.containsKey("rtnCode") && jsonObject.getIntValue("rtnCode") == 0) {
                return true;
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay chYhHw 接收参数 " + content);

        Map<String, Object> params = new HashMap<String, Object>();
        JSONObject ret = new JSONObject();
        try {
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                String paramValue = request.getParameter(paramName);
                params.put(paramName, paramValue);
                LOG.error("pay chYhHw " + paramName + ":" + paramValue);
            }
            LOG.error("pay chYhHw 结束参数");

            String orderId = request.getParameter("orderId");
            String extReserved = request.getParameter("extReserved");
            String amount = request.getParameter("amount");
            String result = request.getParameter("result");
            String sign = request.getParameter("sign");

            if (result == null || !result.equals("0")) {
                ret.put("result", 3);
                return ret.toString();
            }
            String origin = RSA.getSignData(params);
            LOG.error("pay chYhHw 签名原文" + origin);
            LOG.error("pay chYhHw sign" + sign);
            if (!RSA.doCheck(origin, sign, APP_KEY)) {

                String cpSign = RSAUtil.sha256WithRsa(origin.getBytes(), APP_SECRET);

                if (!cpSign.equals(sign)) {

                    LOG.error("pay chYhHw 验签失败");
                    ret.put("result", 1);
                    return ret.toString();
                }
            }

            String[] infos = extReserved.split("_");
            if (infos.length != 4) {
                LOG.error("pay chYhHw 传参不正确");
                ret.put("result", 95);
                return ret.toString();
            }
            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);
            String platId = infos[3];

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = platId;
            payInfo.orderId = orderId;

            payInfo.serialId = serverid + "_" + lordId + "_" + orderId;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(amount);
            payInfo.amount = (int) payInfo.realAmount;
            int retcode = payToGameServer(payInfo);
            if (retcode == 0) {
                LOG.error("pay chYhHw 返回充值成功");
            } else {
                LOG.error("pay chYhHw 充值成功,发货失败" + retcode);
            }
            ret.put("result", 0);
        } catch (Exception e) {
            e.printStackTrace();
            LOG.error("pay chYhHw 支付异常");
            ret.put("result", 94);
        }
        return ret.toString();
    }


    private boolean isJosn(String content) {
        try {
            if (content == null || "".equals(content)) {
                return false;
            }
            com.alibaba.fastjson.JSONObject jsonObject = com.alibaba.fastjson.JSONObject.parseObject(content);
            return true;
        } catch (Exception e) {
            return false;
        }
    }


    private boolean verifyAccount(String userId, String ts, String sign) {
        LOG.error("chYhHw 开始调用sidInfo接口");
        try {
            String checkSign = APP_ID + ts + userId;
            if (RSAUtil.verify(checkSign.getBytes("UTF-8"), LOGIN_KEY, sign)) {
                LOG.error("登陆成功");
                return true;
            } else {
                LOG.error("登陆验签失败");
                return false;
            }
        } catch (Exception e) {
            LOG.error("登陆验签异常");
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }
    }


    private boolean verifyAccount(String userId, String access_token) {
        LOG.error("chYhHw 开始调用sidInfo接口");
        try {
            access_token = URLEncoder.encode(access_token, "utf-8");
            access_token = access_token.replace("+", "%2B");
        } catch (UnsupportedEncodingException e1) {
            e1.printStackTrace();
        }

        Map<String, String> parameter = new HashMap<>();
        parameter.put("nsp_svc", "OpenUP.User.getInfo");
        parameter.put("nsp_ts", String.valueOf(System.currentTimeMillis() / 1000));
        parameter.put("access_token", access_token);

        LOG.error("[请求参数]" + parameter.toString());
        LOG.error("[请求地址]" + serverUrl);

        String result = HttpUtils.sendGet(serverUrl, parameter);
        LOG.error("[响应结果]" + result);
        if (result == null) {
            return false;
        }
        try {
            JSONObject rsp = JSONObject.fromObject(result);
            if (rsp.containsKey("userID")) {
                String uid = rsp.getString("userID");
                if (uid.equals(userId)) {
                    return true;
                }
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

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return null;
    }


    public static void main(String[] s) {


//        try {

//
//        String str = "dVSlaDaPItoMhxYePI414ufHMU4Xd9NdthgTmJNv86f%2Bnp7mceovwollCsKWj9VYeDTiwhxYWWr3oKkHhEkOUucqMusFL%2F8bxPA2kmrOZ1ZB027bi9aq4rdCzHukodVVZEOsubKC%2BO8R9B6YqVsxKR4fMHYhOjFEFpXN76A0VMnYBEvAzqE0kCJ6p4XPFj5vqp78FdIed9%2F3UnvK7HBo2MBKh8MeL3MUJ6GvBytZs1CAbAlF0kLT6%2FPlaryGxLa93zz%2FX4jELd5F3TGLnV1cPohCtxrDNb0nm%2BFKa7UrEocCBI106yUlyZjwBLUoDJ3UZW2mN7%2BeUNm4lnTyqQYk7Q%3D%3D";
//        verifyAccount("1525337379430", "900086000144386036", "2", str,"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAKidOWq2yxJfV+6lvOyzRow0MswFh7HC8YWAHooK8ie0DFrFMBjIFrzJMCSr8eGSQk4T2Ft8Fiqs3UZEvY/iKPduAIkE+shAgoSJ9vDjtjaRp5SA0PRZ8ecrOW9dox3EVUIfVnnAnQGp07x+O0KuZQaha277ViX1p/NAhhDqmDkXAgMBAAECgYEAkmSPKTuzbCwjaCu1r7ynD6tyPvi+K3QZxdLKsQd330jPQS/a5mkydI4oom42/6XAs5E/U46UoFCdfRjJjFbLQTrggBhvrDB84gBKKmuPFE5uLHYuPbrYA6J5KmeclHthuceatgT8cAn4EvLBZHw7LzWd5vdGIHhifEoUOfx12iECQQDyCrFlMdAViGNrfbcruJmBE2YRzmsAU4qObejQlAD9Tdu4mNBfYI30I/LhCZyq93SAcQ+F+hD521HmtS0WNbPVAkEAslaBivI268AmyFwPGGQfQzW0bxHaGG1vqNlcZlXNW/CceYuEIOM9Ii/dShpGQ8jxBUtfWFzI9IP1Gpwo83crOwJAJDVNTGIjStVYaiAoYrX+4LxSLJ/Aig/1TlFK3skFTN902yyhH2OGWNt33gpeEYVrPDutotFB8N7KZcT8tbHa8QJAE0QVKpWQKVfQ2MRZPSFT30bl/znGfe0UqwEQYl3SmaQcw2S3GXZzHEZfeans/VWv9Ap4emtLql63E/Da27J8EQJAF9I0aebRAFmnGQAHfMD7TdsqY2X/x6xppLQOuZ/ntVc2HvKkC2GHMvL1NtUVg1zZXqHF7+kSArydZ5DkREQoiw==");

//
//            List<String> key = new ArrayList<>();
//            key.add("method");
//            key.add("appId");
//            key.add("cpId");
//            key.add("ts");
//            key.add("playerId");
//            key.add("playerSSign");
//            key.add("playerLevel");
//            Collections.sort(key);
//            Map<String, String> val = new HashMap<>();
//            val.put("method", "external.hms.gs.checkPlayerSign");
//            val.put("appId", "10000");
//            val.put("cpId", "1000");
//            val.put("ts", System.currentTimeMillis()+"");
//            val.put("playerId", 100 + "");
//            val.put("playerSSign", "VUOoWexHeQC98OFHyWapgKSACDwBgEHWb6IvPutKO0Z/wSVU3SDoK7/vnaLsYte6cYJu/RVWxoGh8lJfHuMoMucKutoNEXnAnPgTG5cfXf79DCtTnhMJ3lHBjaYFD03RWb2XBRKlnF7m455DeU2bvPZOsi7BhTDNPD0bTxY7PWlASLCSX7C7WqHN4/AWxDiU+ki2pPBstuSDecoUQQATBU35bQE2V7DtOsoGAhseuKXZe7yExMqszyZHLKaaqsbqq1rCua6FvJtwlwO82eY7N5kyW29r3MQ/uW1XGh4aPDods9UfD90BSLoPPmLjV9tREX/HFIdxkZ3FVWbkcWR4YQ==");
//            val.put("playerLevel", 10 + "");
//
//
//            StringBuilder sb = new StringBuilder();
//
//            for (String k : key) {
//                sb.append(k);
//                sb.append("=");
//                sb.append(URLEncoder.encode(val.get(k), "utf-8"));
//                sb.append("&");
//            }
//
//            String signStr = sb.substring(0, sb.length() - 1);
//
//            String cpSign = RSAUtil.sha256WithRsa(signStr.getBytes(), "MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCHJJ1kxhOXDh4M9QgXj2sXahxG7clGnWDp5YW9f/+Xyf2RzZma1JB76KqXh2ZNyJfpG/4tsUqm1KBQ3w1glvsvUsCcuiAhVmT3CkN7+M/S+ttcXIlNfT+x2UH4h50d1IPLr7qSjgiBkPcW2WFFXxRfaUqSg7xhLp+9ydXJJFQbvTBKCpr2HFRl4DEuF5SxganG8SQau/swCf2l3lHnrIm4ER5B+O4RNqYr/AMo6tge1LXaYp9ss8TM3VmTTGNHGcIaPvSIeBsT4XolhkZ0RyyT++m1ABSKn1kA8Rv5vjzj5WbHDi8LefreQ3gcBax26h/6tbvgTgMwIDzokRrUOM39AgMBAAECggEAcpm7GtTZkfP3ybcUKJ6HCvEBj6hfUZFtuIrZccwUW4x/id/WzTRKXbj8yMiaGYXsRFJnpim9C2ItnMa5mloOIaBEE+PGEV8o+VDrzzo8SkZONLGIAX0fwVpiFjYyJzSqmtSnG1Z0oiLjVa37TY+GQC6SfVJXMfYOoiuBLjOvW2FB8AJQX6G8dU6S4WZc1RdJ9ZyyQgcfKtt/kvja/JroMkOx2SQ13Yd7BU19xFVJCPiEPF9K+CtTIYO/hkHdUwh8+p74QaEHemJ1HfE2bFtZMEplBoSa06zwzUVx0WV1Y3j/qg7rxrDNl6ITmWTyQEn3bdJn0XPrvcRmv4sgce1K4QKBgQDWNyEUlg3yMKJyNmnK8oLUggXNkBC7ayRkN67MsUdS9gsFBhlOZeocrzb+T9GZUpVfDGmLO5708P8eZbRDDNRSVMyr0eV89sPXx579kyV9/nMzA65LasldlNC15gyr61/ldp6Uleb3bUEeYe7AkRnzSrJfLOTLUoTi7huVY59vKQKBgQChgP/FoWD9U/Ahz72IGS3CFFeHZMjFQfryrVBu5aL8iXeTj9ansKeUbIecYW3UqS+HbO6vbx+VvHeG5wlSEbernMNWrny5FQzeichKjbOkXmp50dQVvuebyvPYaIAkB7BFLEXqk0rBn5TPPQFS4bLcXe/xeCkF0Gd+uBrI4IpGtQKBgG1uFjkU+qTZUXL09xBU2J7EmUBMsy966UlE5MfuXBg2VqTHW9Af4furSnWZwuIHPQUkKxqUZ3yLTFhz7iU+fYxdg3zWqdwvlxY5BLBXJhT6ElFiNPyT3bAvoHr7vUdp40AuW45eEXIeXuCteLDorxAI/Zv/LBXt3rKqnm6vSLgZAoGASa7dAoGaCnndOM/anNk/8yfstyzYHIb5wvYnmDDUp3rgP0aEnIUQL7tEM6iPv1JhCNw+GXQNaPdPYRDPQ84pifY/eLCq3pYoBO+/naQAraEV2vZMWI98g6uYjMdAjy+i0CxeyaLhnGz+K36dt/6Y58lDy1sS/EAUt8+vCK7I53ECgYEAu/Sup6U7CPpNarNbfgNJGpNtijMWSwuM5cwB/7T1uhiA9pR9pxkjOA2RxopokqmjfhKSNi6MLSfkxayK/x/33VqJotqMylQns2G9ZlAJ+zUkB/Ihe1eSkP14e3jiFDaYuXwdW8JUUHVXv+dagCdu/aTZdrJg9UmrnYY6qx9F7gc=");
//
//            val.put("cpSign",cpSign);
//
//            LOG.error(URLEncoder.encode(cpSign, "utf-8"));
//
//            String result = HttpHelper.doPost("https://gss-cn.game.hicloud.com/gameservice/api/gbClientApi", val);
//
//            LOG.error("草花华为签名验证结果 " + result);
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
    }

}
