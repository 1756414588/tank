package com.account.plat.impl.qh360;

import javax.net.ssl.*;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

public class QihuUtil {
//	private String url = "https://esales.the9.com/esa/DealerLogin.php?txt_sLogin=andysmile234&pas_sPwd=343211&userstatus=1";

    private myX509TrustManager xtm = new myX509TrustManager();

    private myHostnameVerifier hnv = new myHostnameVerifier();

    public QihuUtil() {
        SSLContext sslContext = null;
        try {
            sslContext = SSLContext.getInstance("TLS"); // 或SSL
            X509TrustManager[] xtmArray = new X509TrustManager[]{xtm};
            sslContext.init(null, xtmArray, new java.security.SecureRandom());
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (sslContext != null) {
            HttpsURLConnection.setDefaultSSLSocketFactory(sslContext.getSocketFactory());
        }
        HttpsURLConnection.setDefaultHostnameVerifier(hnv);
    }
}

/**
 * 重写三个方法
 *
 * @author Administrator
 */
class myX509TrustManager implements X509TrustManager {
    public X509Certificate[] getAcceptedIssuers() {
        return null;
    }

    @Override
    public void checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException {
        // TODO Auto-generated method stub

    }

    @Override
    public void checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException {
        // TODO Auto-generated method stub
//		LOG.error("cert: " + chain[0].toString() + ", authType: " + authType);
    }
}

/**
 * 重写一个方法
 *
 * @author Administrator
 */
class myHostnameVerifier implements HostnameVerifier {
    @Override
    public boolean verify(String hostname, SSLSession session) {
        //LOG.error("Warning: URL Host: " + hostname + " vs. " + session.getPeerHost());
        return true;
    }
}