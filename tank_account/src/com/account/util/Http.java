package com.account.util;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Map;

public class Http {
    public static String post(String requestUrl, Map<String, String> param) {
        String destUrl = requestUrl;


        URL url;
        String paramStr = null;
        try {
            if (null != param && param.size() > 0) {
                StringBuilder sb = new StringBuilder();
                for (Map.Entry<String, String> p : param.entrySet()) {
                    sb.append(p.getKey());
                    sb.append("=");
                    sb.append(URLEncoder.encode(p.getValue(), "utf-8"));
                    sb.append("&");
                }
                paramStr = sb.substring(0, sb.toString().length() - 1);


                String u = destUrl;
                System.out.print(u);
                //LOG.error("?"+paramStr);
                url = new URL(u);
            } else {
                url = new URL(destUrl);
            }

            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setConnectTimeout(10000);
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);

            OutputStreamWriter out = new OutputStreamWriter(connection.getOutputStream());
            out.write(paramStr == null ? "" : paramStr); // 向页面传递数据。post的关键所在！
            out.flush();
            out.close();

            BufferedInputStream in = new BufferedInputStream(connection.getInputStream());

            BufferedReader reader = new BufferedReader(new InputStreamReader(in));

            String s = null;
            StringBuilder rspBuilder = new StringBuilder();
            while (null != (s = reader.readLine())) {
                rspBuilder.append(s);
            }
            in.close();
            reader.close();
            return rspBuilder.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }

    public static String post(String requestUrl, String paramStr) {

        try {
            URL url = new URL(requestUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setConnectTimeout(3000);
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
//            connection.setRequestProperty("Content-type","text/plain");
            OutputStreamWriter out = new OutputStreamWriter(connection.getOutputStream());
            out.write(paramStr);
            out.flush();
            out.close();

            BufferedInputStream in = new BufferedInputStream(connection.getInputStream());

            BufferedReader reader = new BufferedReader(new InputStreamReader(in));

            String s = null;
            StringBuilder rspBuilder = new StringBuilder();
            while (null != (s = reader.readLine())) {
                rspBuilder.append(s);
            }
            in.close();
            reader.close();
            return rspBuilder.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }

    public static String requestMockPost(String requestUrl, String[]... params) {

        String destUrl = requestUrl;
        // LOG.error("request url:"+requestUrl);
        URL url;
        try {

            url = new URL(destUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setConnectTimeout(10000);
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
            String paramStr = null;
            if (null != params) {
                StringBuilder builder = new StringBuilder();
                for (String[] param : params) {
                    builder.append("&").append(param[0]).append("=").append(URLEncoder.encode(param[1], "UTF-8"));
                }
                paramStr = builder.substring(1);
            }
            OutputStreamWriter out = new OutputStreamWriter(connection.getOutputStream());
            out.write(paramStr == null ? "" : paramStr); // 向页面传递数据。post的关键所在！
            out.flush();
            out.close();

            BufferedInputStream in = new BufferedInputStream(connection.getInputStream());

            BufferedReader reader = new BufferedReader(new InputStreamReader(in));

            String s = null;
            // System.out.print("response:");
            StringBuilder rspBuilder = new StringBuilder();
            while (null != (s = reader.readLine())) {
                rspBuilder.append(s);
                // LOG.error(s);
            }
            in.close();
            reader.close();
            return rspBuilder.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }

}
