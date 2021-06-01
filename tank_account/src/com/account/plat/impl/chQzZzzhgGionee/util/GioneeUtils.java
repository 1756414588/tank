package com.account.plat.impl.chQzZzzhgGionee.util;

import java.io.OutputStream;
import java.security.NoSuchAlgorithmException;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import javax.net.ssl.HttpsURLConnection;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.security.KeyManagementException;
import java.security.NoSuchProviderException;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import org.apache.commons.lang.CharEncoding;

import java.security.InvalidKeyException;
import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.X509EncodedKeySpec;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class GioneeUtils {

    private static final String MAC_NAME = "HmacSHA1";

    private static final String SIGN_ALGORITHMS = "SHA1WithRSA";

    /**
     * 采取HmacSHA1方式进行mac签名 格式如下：x24EC52kA632aDSY13jZHqrxkPY=
     */
    public static String macSig(String host, String port, String secret, String timestamp, String nonce, String method,
                                String url) {

        StringBuffer buffer = new StringBuffer();
        buffer.append(timestamp).append("\n");
        buffer.append(nonce).append("\n");
        buffer.append(method.toUpperCase()).append("\n");
        buffer.append(url).append("\n");
        buffer.append(host.toLowerCase()).append("\n");
        buffer.append(port).append("\n");
        buffer.append("\n");
        String text = buffer.toString();

        byte[] ciphertext = null;
        Mac mac = null;
        try {
            mac = Mac.getInstance(MAC_NAME);
            mac.init(new SecretKeySpec(StringUtil.getBytes(secret), MAC_NAME));
            ciphertext = mac.doFinal(StringUtil.getBytes(text));
        } catch (Throwable e) {
            e.printStackTrace();
            return null;
        }

        String sigString = Base64.encodeToString(ciphertext, Base64.DEFAULT);
        // 生成的字符串最后一个字符是"\n"
        sigString.replace("\n", "");
        return sigString;
    }

    /**
     * 生成如下格式的字符串： MAC
     * id="D4D91AA8707C4201B09A108E6156CB14",ts="1386832975",nonce="9444729f",mac="XorG3EMLBz9VLwwvFEq4lJNop1o="
     */
    public static String builderAuthorization(String appKey, String ts, String nonce, String mac) {
        StringBuilder authStr = new StringBuilder();
        authStr.append("MAC ");
        authStr.append(String.format("id=\"%s\"", appKey));
        authStr.append(String.format(",ts=\"%s\"", ts));
        authStr.append(String.format(",nonce=\"%s\"", nonce));
        authStr.append(String.format(",mac=\"%s\"", mac));
        return authStr.toString();

    }

    /**
     * 发送账号验证请求
     *
     * @param verify_url
     * @param authorization
     * @param amigoToken
     * @return
     */
    public static String sendJsonPost(String verify_url, String authorization, String amigoToken) {
        HttpsURLConnection httpURLConnection = null;
        OutputStream out;

        TrustManager[] tm = {new MyX509TrustManager()};
        String responseBody = null;
        try {
            SSLContext sslContext = SSLContext.getInstance("SSL", "SunJSSE");
            sslContext.init(null, tm, new java.security.SecureRandom());
            // 从上述SSLContext对象中得到SSLSocketFactory对象
            SSLSocketFactory ssf = sslContext.getSocketFactory();
            URL sendUrl = new URL(verify_url);
            httpURLConnection = (HttpsURLConnection) sendUrl.openConnection();
            httpURLConnection.setSSLSocketFactory(ssf);
            httpURLConnection.setDoInput(true); // true表示允许获得输入流,读取服务器响应的数据,该属性默认值为true
            httpURLConnection.setDoOutput(true); // true表示允许获得输出流,向远程服务器发送数据,该属性默认值为false
            httpURLConnection.setUseCaches(false); // 禁止缓存
            int timeout = 30000;
            httpURLConnection.setReadTimeout(timeout); // 30秒读取超时
            httpURLConnection.setConnectTimeout(timeout); // 30秒连接超时
            String method = "POST";
            httpURLConnection.setRequestMethod(method);
            httpURLConnection.setRequestProperty("Content-Type", "application/json");
            httpURLConnection.setRequestProperty("Authorization", authorization);
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
            responseBody = new String(buffer.toByteArray(), "UTF-8");

        } catch (KeyManagementException e) {
            e.printStackTrace();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (NoSuchProviderException e) {
            e.printStackTrace();
        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return responseBody;

    }

    /**
     * 支付回调签名验证
     *
     * @param content   待检测的组装签名
     * @param sign      sdk服务器传递的签名
     * @param publicKey 公钥
     * @return
     */
    public static boolean doCheck(String content, String sign, String publicKey) throws NoSuchAlgorithmException,
            IOException, InvalidKeySpecException, InvalidKeyException, SignatureException {
        String charset = CharEncoding.UTF_8;

        KeyFactory keyFactory = KeyFactory.getInstance("RSA");
        byte[] encodedKey = Base64.decodeLines(publicKey);
        PublicKey pubKey = keyFactory.generatePublic(new X509EncodedKeySpec(encodedKey));

        java.security.Signature signature = java.security.Signature.getInstance(SIGN_ALGORITHMS);

        signature.initVerify(pubKey);
        signature.update(content.getBytes(charset));

        boolean bverify = signature.verify(Base64.decodeLines(sign));
        return bverify;

    }

    static class MyX509TrustManager implements X509TrustManager {

        public void checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException {
        }

        public void checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException {
        }

        public X509Certificate[] getAcceptedIssuers() {
            return null;
        }
    }

	/*public static void main(String[] args) {
		String mac = macSig("id.gionee.com", "443", "2B66099A8F494C5F8C05B6C5D1F72842", "1529002556",
				"A1ED895833A447AB89090E2358B7C1DF", "POST", "/account/verify.do");
		LOG.error(mac);
	}*/
}
