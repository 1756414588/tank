package com.account.plat.impl.sogou;

import java.io.BufferedReader;
import java.io.InputStreamReader;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.util.EntityUtils;

public class HttpHelper {
    public static final String UTF8_ENCODE = "UTF-8";
    public static final ContentType CONTENT_TYPE = ContentType.create("text/plain", "UTF-8");

    static public String doPost(String url, String body) throws Exception {
        String responseBody = null;
        CloseableHttpClient httpclient = HttpClients.createDefault();
        try {
            HttpPost httpPost = new HttpPost(url);
            httpPost.setEntity(new StringEntity(body, CONTENT_TYPE));
            CloseableHttpResponse response = httpclient.execute(httpPost);
            int statusCode = response.getStatusLine().getStatusCode();
            if (statusCode != 200) {
                return responseBody;
            }
            try {
                HttpEntity httpEntity = response.getEntity();
                if (httpEntity != null) {
                    responseBody = EntityUtils.toString(response.getEntity());
                }
            } finally {
                response.close();
            }
        } finally {
            httpclient.close();
        }

        return responseBody;
    }

    @SuppressWarnings("deprecation")
    public static String doGet(final String url) {
        StringBuffer stringBuffer = new StringBuffer();
        HttpEntity entity = null;
        BufferedReader in = null;
        HttpResponse response = null;
        try {
            DefaultHttpClient httpclient = new DefaultHttpClient();
            HttpParams params = httpclient.getParams();
            HttpConnectionParams.setConnectionTimeout(params, 20000);
            HttpConnectionParams.setSoTimeout(params, 20000);
            // HttpPost httppost = new HttpPost(url);
            HttpGet httpGet = new HttpGet(url);
            httpGet.setHeader("Content-Type", "application/x-www-form-urlencoded");

            // httppost.setEntity(new ByteArrayEntity(body.getBytes("UTF-8")));
            response = httpclient.execute(httpGet);
            entity = response.getEntity();
            in = new BufferedReader(new InputStreamReader(entity.getContent()));
            String ln;
            while ((ln = in.readLine()) != null) {
                stringBuffer.append(ln);
                stringBuffer.append("\r\n");
            }
            httpclient.getConnectionManager().shutdown();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return stringBuffer.toString();
    }

}
