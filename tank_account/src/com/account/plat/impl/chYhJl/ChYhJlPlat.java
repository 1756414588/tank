package com.account.plat.impl.chYhJl;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;
import java.util.UUID;

import javax.annotation.PostConstruct;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import javax.net.ssl.X509TrustManager;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.chYhJl.rea.RSASignature;
import com.account.plat.impl.chYhJl.util.Base64;
import com.account.plat.impl.chYhJl.util.Order;
import com.account.plat.impl.chYhJl.util.PayUtil;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.util.RandomHelper;
import com.alibaba.fastjson.JSON;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs.Builder;

class GioneeAccount {
    public String pid;
    public String na;
}

@Component
public class ChYhJlPlat extends PlatBase {
    private static final String port = "443";
    private static final String verify_url = "https://id.gionee.com:" + port
            + "/account/verify.do";
    // static String apiKey = "7EBF116B7DC847C4A109F51C858320E4"; //
    // 替换成商户申请获取的APIKey
    // static String secretKey = "1F2DF0D4022B48DEA3E18537E4159DF3"; //
    // 替换成商户申请获取的SecretKey
    private static final String host = "id.gionee.com";
    private static final String url = "/account/verify.do";
    private static final String method = "POST";
    private static final String GIONEE_PAY_INIT = "https://pay.gionee.com/order/create";
    // 成功响应状态码
    private static final String CREATE_SUCCESS_RESPONSE_CODE = "200010000";

    private static final String PAY_CB_URL = "http://chYhJl.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=chYhJl";
//	private static final String PAY_CB_URL = "http://gionee.gmzg.hundredcent.com:10001/legend_account/account/payCallback.do?plat=gionee";

    // sdk server的接口地址
    private static String VERIRY_URL;

    private static String API_KEY;

    private static String SECRET_KEY;

    private static String PRIVATE_KEY;

    private static String PUBLIC_KEY;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chYhJl/",
                "plat.properties");
        API_KEY = properties.getProperty("API_KEY");
        SECRET_KEY = properties.getProperty("SECRET_KEY");
        VERIRY_URL = properties.getProperty("VERIRY_URL");
        PRIVATE_KEY = properties.getProperty("PRIVATE_KEY");
        PUBLIC_KEY = properties.getProperty("PUBLIC_KEY");
    }

    static class MyX509TrustManager implements X509TrustManager {

        @Override
        public void checkClientTrusted(X509Certificate[] chain, String authType)
                throws CertificateException {
            // TODO Auto-generated method stub

        }

        @Override
        public void checkServerTrusted(X509Certificate[] chain, String authType)
                throws CertificateException {
            // TODO Auto-generated method stub

        }

        @Override
        public X509Certificate[] getAcceptedIssuers() {
            // TODO Auto-generated method stub
            return null;
        }

    }

    static class CryptoUtility {

        private static final String MAC_NAME = "HmacSHA1";

        public static String macSig(String host, String port, String macKey,
                                    String timestamp, String nonce, String method, String uri) {
            // 1. build mac string
            // 2. hmac-sha1
            // 3. base64-encoded

            StringBuffer buffer = new StringBuffer();
            buffer.append(timestamp).append("\n");
            buffer.append(nonce).append("\n");
            buffer.append(method.toUpperCase()).append("\n");
            buffer.append(uri).append("\n");
            buffer.append(host.toLowerCase()).append("\n");
            buffer.append(port).append("\n");
            buffer.append("\n");
            String text = buffer.toString();

            byte[] ciphertext = null;
            try {
                ciphertext = hmacSHA1Encrypt(macKey, text);
            } catch (Throwable e) {
                e.printStackTrace();
                return null;
            }

            String sigString = Base64
                    .encodeToString(ciphertext, Base64.DEFAULT);
            return sigString;
        }

        public static byte[] hmacSHA1Encrypt(String encryptKey,
                                             String encryptText) throws InvalidKeyException,
                NoSuchAlgorithmException {
            Mac mac = Mac.getInstance(MAC_NAME);
            mac.init(new SecretKeySpec(StringUtil.getBytes(encryptKey),
                    MAC_NAME));
            return mac.doFinal(StringUtil.getBytes(encryptText));
        }

    }

    static class StringUtil {
        public static final String UTF8 = "UTF-8";
        private static final byte[] BYTEARRAY = new byte[0];

        public static boolean isNullOrEmpty(String s) {
            if (s == null || s.isEmpty() || s.trim().isEmpty()) {
                return true;
            }
            return false;
        }

        public static String randomStr() {
            return CamelUtility.uuidToString(UUID.randomUUID());
        }

        public static byte[] getBytes(String value) {
            return getBytes(value, UTF8);
        }

        public static byte[] getBytes(String value, String charset) {
            if (isNullOrEmpty(value)) {
                return BYTEARRAY;
            }
            if (isNullOrEmpty(charset)) {
                charset = UTF8;
            }
            try {
                return value.getBytes(charset);
            } catch (UnsupportedEncodingException e) {
                return BYTEARRAY;
            }
        }
    }

    static class CamelUtility {
        public static final int SizeOfUUID = 16;
        private static final int SizeOfLong = 8;
        private static final int BitsOfByte = 8;
        private static final int MBLShift = (SizeOfLong - 1) * BitsOfByte;

        private static final char[] HEX_CHAR_TABLE = {'0', '1', '2', '3', '4',
                '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

        public static String uuidToString(UUID uuid) {
            long[] ll = {uuid.getMostSignificantBits(),
                    uuid.getLeastSignificantBits()};
            StringBuilder str = new StringBuilder(SizeOfUUID * 2);
            for (int m = 0; m < ll.length; ++m) {
                for (int i = MBLShift; i > 0; i -= BitsOfByte)
                    formatAsHex((byte) (ll[m] >>> i), str);
                formatAsHex((byte) (ll[m]), str);
            }
            return str.toString();
        }

        public static void formatAsHex(byte b, StringBuilder s) {
            s.append(HEX_CHAR_TABLE[(b >>> 4) & 0x0F]);
            s.append(HEX_CHAR_TABLE[b & 0x0F]);
        }

    }

    private JSONObject packResponse(int status, String msg) {
        JSONObject res = new JSONObject();
        res.put("status", status);
        res.put("msg", msg);
        return res;
    }

    private JSONObject packResponse(int status, String msg, String time) {
        JSONObject res = new JSONObject();
        res.put("status", status);
        res.put("msg", msg);
        res.put("time", time);
        return res;
    }

    // verify 方法封装了 验证方法，调用此方法即可完成帐号安全验证
    public static String verify(String amigoToken) {
        HttpURLConnection httpURLConnection = null;
        OutputStream out;

        // TrustManager[] tm = { new MyX509TrustManager() };
        try {
            // SSLContext sslContext = SSLContext.getInstance("SSL", "SunJSSE");
            // sslContext.init(null, tm, new java.security.SecureRandom());
            // // 从上述SSLContext对象中得到SSLSocketFactory对象
            // SSLSocketFactory ssf = sslContext.getSocketFactory();
            URL sendUrl = new URL(VERIRY_URL);
            httpURLConnection = (HttpURLConnection) sendUrl.openConnection();
            // httpURLConnection.setSSLSocketFactory(ssf);
            httpURLConnection.setDoInput(true); // true表示允许获得输入流,读取服务器响应的数据,该属性默认值为true
            httpURLConnection.setDoOutput(true); // true表示允许获得输出流,向远程服务器发送数据,该属性默认值为false
            httpURLConnection.setUseCaches(false); // 禁止缓存
            int timeout = 30000;
            httpURLConnection.setReadTimeout(timeout); // 30秒读取超时
            httpURLConnection.setConnectTimeout(timeout); // 30秒连接超时
            String method = "POST";
            httpURLConnection.setRequestMethod(method);
            httpURLConnection.setRequestProperty("Content-Type",
                    "application/json");
            httpURLConnection.setRequestProperty("Authorization",
                    builderAuthorization());
            out = httpURLConnection.getOutputStream();
            out.write(amigoToken.getBytes());
            out.flush();
            out.close();
            InputStream in = httpURLConnection.getInputStream();
            ByteArrayOutputStream buffer = new ByteArrayOutputStream();
            byte[] buff = new byte[1024];
            int len = -1;
            while ((len = in.read(buff)) != -1) {
                buffer.write(buff, 0, len);
            }

            String back = buffer.toString();
            System.out
                    .println(String.format("verify sucess response:%s", back));
            return back;
        } catch (Exception e) {
            //LOG.error("ChYhJl verify exception");
            e.printStackTrace();
        }

        return null;
    }

    private static String builderAuthorization() {

        Long ts = System.currentTimeMillis() / 1000;
        String nonce = StringUtil.randomStr().substring(0, 8);
        String mac = CryptoUtility.macSig(host, port, SECRET_KEY,
                ts.toString(), nonce, method, url);
        mac = mac.replace("\n", "");
        StringBuilder authStr = new StringBuilder();
        authStr.append("MAC ");
        authStr.append(String.format("id=\"%s\"", API_KEY));
        authStr.append(String.format(",ts=\"%s\"", ts));
        authStr.append(String.format(",nonce=\"%s\"", nonce));
        authStr.append(String.format(",mac=\"%s\"", mac));
        return authStr.toString();
    }

    @Override
    public GameError doLogin(DoLoginRq req, Builder response) {
        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion()
                || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        // String[] vParam = sid.split("_");
        // if (vParam.length < 1) {
        // return GameError.PARAM_ERROR;
        // }

        GioneeAccount gioneeAccount = verifyAccount(sid);
        if (gioneeAccount == null) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(),
                gioneeAccount.pid);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(gioneeAccount.pid);
            account.setAccount(getPlatNo() + "_" + gioneeAccount.pid);
            account.setPasswd(gioneeAccount.pid);
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

    // @Override
    // public GameError doLogin(JSONObject param, JSONObject response) {
    // // TODO Auto-generated method stub
    // if (!param.containsKey("sid") || !param.containsKey("baseVersion") ||
    // !param.containsKey("version") || !param.containsKey("deviceNo")) {
    // return GameError.PARAM_ERROR;
    // }
    //
    // String sid = param.getString("sid");
    // String baseVersion = param.getString("baseVersion");
    // String versionNo = param.getString("version");
    // String deviceNo = param.getString("deviceNo");
    //
    // GioneeAccount gioneeAccount = verifyAccount(sid);
    // if (gioneeAccount == null) {
    // return GameError.SDK_LOGIN;
    // }
    //
    // Account account = accountDao.selectByPlatId(getPlatNo(),
    // gioneeAccount.pid);
    // if (account == null) {
    // String token = RandomHelper.generateToken();
    // account = new Account();
    // account.setPlatNo(this.getPlatNo());
    // account.setPlatId(gioneeAccount.pid);
    // account.setAccount(getPlatNo() + "_" + gioneeAccount.pid);
    // account.setPasswd(gioneeAccount.pid);
    // account.setBaseVersion(baseVersion);
    // account.setVersionNo(versionNo);
    // account.setToken(token);
    // account.setDeviceNo(deviceNo);
    // Date now = new Date();
    // account.setLoginDate(now);
    // account.setCreateDate(now);
    // accountDao.insertWithAccount(account);
    // } else {
    // String token = RandomHelper.generateToken();
    // account.setToken(token);
    // account.setBaseVersion(baseVersion);
    // account.setVersionNo(versionNo);
    // account.setDeviceNo(deviceNo);
    // account.setLoginDate(new Date());
    // accountDao.updateTokenAndVersion(account);
    // }
    //
    // GameError authorityRs = super.checkAuthority(account);
    // if (authorityRs != GameError.OK) {
    // return authorityRs;
    // }
    //
    // response.put("recent", super.getRecentServers(account));
    // response.put("keyId", account.getKeyId());
    // response.put("token", account.getToken());
    //
    // if (isActive(account)) {
    // response.put("active", 1);
    // } else {
    // response.put("active", 0);
    // }
    //
    // return GameError.OK;
    // }

    public static String getSign(HashMap<String, String> params) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;

        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("sign") || k.equals("msg") || k.equals("plat")) {
                continue;
            }

            if (params.get(k) == null) {
                continue;
            }
            v = (String) params.get(k);

            if (v.equals("0") || v.equals("")) {
                continue;
            }

            if (i != 0) {
                str += "&";
            }

            str += k + "=" + v;
        }
        //LOG.error("getSign:" + str);
        return str;
    }

    @Override
    public String payBack(WebRequest request, String content,
                          HttpServletResponse response) {
        LOG.error("pay ChYhJl");
        LOG.error("[接收到的参数]" + content);

        Map<String, String[]> paramterMap = request.getParameterMap();
        HashMap<String, String> params = new HashMap<String, String>();
        String k, v;
        Iterator<String> iterator = paramterMap.keySet().iterator();
        while (iterator.hasNext()) {
            k = iterator.next();
            String arr[] = paramterMap.get(k);
            v = (String) arr[0];
            params.put(k, v);
            LOG.error(k + "=" + v);
        }

        String checkContent = getSign(params);
        String sign = params.get("sign");
        /****************************** 签名验证 *******************************************/
        try {
            boolean isValid = false;
            isValid = RSASignature.doCheck(checkContent, sign, PUBLIC_KEY,
                    "UTF-8");
            if (isValid) {
                String api_key = params.get("api_key");
                if (!API_KEY.equals(api_key)) {
                    LOG.error("apikey 不一致");
                    return "error";
                }
                String deal_price = params.get("deal_price");
                String out_order_no = params.get("out_order_no");

                String[] infos = out_order_no.split("_");
                if (infos.length != 3) {
                    LOG.error("传参错误");
                    return "error";
                }
                Long lordId = Long.valueOf(infos[1]);
                int serverid = Integer.valueOf(infos[0]);
                // int rechargeId = Integer.valueOf(infos[2]);
//				String platId = infos[1];

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.platId = params.get("user_id");
                payInfo.orderId = out_order_no;

                payInfo.serialId = serverid + "_" + lordId + "_" + infos[2];
                payInfo.serverId = serverid;
                payInfo.roleId = lordId;
                payInfo.realAmount = Double.valueOf(deal_price);
                payInfo.amount = (int) payInfo.realAmount;
                int retcode = payToGameServer(payInfo);
                if (retcode == 0) {
                    LOG.error("返回充值成功");
                    return "success";
                } else {
                    LOG.error("返回充值失败");
                    return "success";
                }
            }

            LOG.error("ChYhJl 充值验签失败");
            return "error";
        } catch (Exception e) {
            e.printStackTrace();
            LOG.error("ChYhJl 充值异常");
            return "error";
        }

    }

    private GioneeAccount verifyAccount(String sid) {
        LOG.error("ChYhJl 开始调用sidInfo接口");
        String result = verify(sid);
        // post方式调用服务器接口,请求的body内容是参数json格式字符串
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

        try {
            JSONObject rsp = JSONObject.fromObject(result);
            if (rsp.containsKey("r")) {
                LOG.error("ChYhJl 验证失败");
                return null;
            }

            GioneeAccount gioneeAccount = new GioneeAccount();
            gioneeAccount.pid = rsp.getString("u");
            gioneeAccount.na = rsp.getString("na");
            // JSONArray p = rsp.getJSONArray("ply");
            // JSONObject pInfo = p.getJSONObject(0);
            // if (pInfo.containsKey("pid")) {
            // gioneeAccount.pid = pInfo.getString("pid");
            // gioneeAccount.na = pInfo.getString("na");
            // }
            return gioneeAccount;
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常");
            e.printStackTrace();
        } finally {
            LOG.error("gionee调用sidInfo接口结束");
        }

        return null;

    }

    @Override
    public String order(WebRequest request, String content) {
        LOG.error("chYhJl 创建订单");
        String player_id = request.getParameter("player_id");
        String deal_price = request.getParameter("deal_price");
        String out_order_no = request.getParameter("out_order_no");
        String subject = request.getParameter("subject");
        String m_submitTime = request.getParameter("submitTime");
        LOG.error("m_submitTime=" + m_submitTime);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        String paysubtime = sdf.format(new Date(Long.valueOf(m_submitTime)));
        LOG.error("paysubtime=" + paysubtime);
        Timestamp submitTime = new Timestamp(Long.valueOf(paysubtime));
        LOG.error("submitTime=" + paysubtime);

        Timestamp expireTime = new Timestamp(
                submitTime.getTime() + 60 * 60 * 1000L);
        Order order = new Order(out_order_no, player_id, subject, API_KEY,
                new BigDecimal(deal_price), new BigDecimal(deal_price),
                submitTime, expireTime, PAY_CB_URL);

        String requestBody = null;
        try {
            requestBody = PayUtil.wrapCreateOrder(order, PRIVATE_KEY, "1");
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            LOG.error("chYhJl 创建订单异常");
            return packResponse(1, "创建订单异常").toString();
        }

        String response = null;
        try {
            response = HttpUtils.sentPost(GIONEE_PAY_INIT, requestBody);
        } catch (Exception e) {
            // TODO : 处理异常;
            LOG.error("ChYhJl 网络异常");
            return packResponse(2, "ChYhJl 网络异常").toString();
        }

        JSONObject json = (JSONObject) JSONObject.fromObject(response);

        LOG.error(response);

        if (CREATE_SUCCESS_RESPONSE_CODE.equals(json.getString("status"))) {

            String orderNo = (String) json.getString("order_no");

            LOG.error("orderNo :" + orderNo);

            if (orderNo == null || "".equals(orderNo)) {
                // TODO: 如果返回orderNo为空，处理异常
                return packResponse(3, "ChYhJl 订单号异常").toString();
            }

            // TODO : 处理商户逻辑
            // return packResponse(0, "OK", order.getSubmitTime()).toString();
            return response.toString();
        }

        // TODO : 处理异常状态
        return packResponse(3, "创建订单失败").toString();
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
        return null;
    }
}
