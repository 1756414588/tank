package com.game.util;

import java.io.*;
import java.net.*;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

public class HttpUtils {
    private static final int TIME_OUT = 5;

    /**
     * 通过HTTP GET 发送参数
     *
     * @param httpUrl
     * @param parameter
     */
    public static String sendGet(String httpUrl, Map<String, String> parameter) {
        if (parameter == null || httpUrl == null) {
            return null;
        }
        StringBuilder sb = new StringBuilder();
        Iterator<Entry<String, String>> iterator = parameter.entrySet().iterator();
        while (iterator.hasNext()) {
            if (sb.length() > 0) {
                sb.append('&');
            }
            Entry<String, String> entry = iterator.next();
            String key = entry.getKey();
            String value;
            try {
                value = URLEncoder.encode(entry.getValue(), "UTF-8");
            } catch (UnsupportedEncodingException e) {
                value = "";
            }
            sb.append(key).append('=').append(value);
        }
        String urlStr = null;
        if (httpUrl.lastIndexOf('?') != -1) {
            urlStr = httpUrl + '&' + sb.toString();
        } else {
            urlStr = httpUrl + '?' + sb.toString();
        }
        HttpURLConnection httpCon = null;
        String responseBody = null;
        try {
            URL url = new URL(urlStr);
            httpCon = (HttpURLConnection) url.openConnection();
            httpCon.setDoOutput(true);
            httpCon.setRequestMethod("GET");
            httpCon.setConnectTimeout(TIME_OUT * 1000);
            httpCon.setReadTimeout(TIME_OUT * 1000);
            // 开始读取返回的内容
            InputStream in = httpCon.getInputStream();
            byte[] readByte = new byte[1024];
            // 读取返回的内容
            int readCount = in.read(readByte, 0, 1024);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            while (readCount != -1) {
                baos.write(readByte, 0, readCount);
                readCount = in.read(readByte, 0, 1024);
            }
            responseBody = new String(baos.toByteArray(), "UTF-8");
            baos.close();
        } catch (Exception e) {
            LogUtil.error(e);
        } finally {
            if (httpCon != null) httpCon.disconnect();
        }
        return responseBody;
    }

    /**
     * 使用HTTP POST 发送文本
     *
     * @param httpUrl  发送的地址
     * @param postBody 发送的内容
     * @return 返回HTTP SERVER的处理结果,如果返回null,发送失败
     */
    public static String sentPost(String httpUrl, String postBody) {
        return sendPost(httpUrl, postBody, "UTF-8", null);
    }

    /**
     * 使用HTTP POST 发送文本
     *
     * @param httpUrl  发送的地址
     * @param postBody 发送的内容
     * @return 返回HTTP SERVER的处理结果,如果返回null,发送失败
     */
    public static String sentPost(String httpUrl, String postBody, String encoding) {
        return sendPost(httpUrl, postBody, encoding, null);
    }

    /**
     * 使用HTTP POST 发送文本
     *
     * @param httpUrl   目的地址
     * @param postBody  post的包体
     * @param headerMap 增加的Http头信息
     * @return
     */
    public static String sentPost(String httpUrl, String postBody, Map<String, String> headerMap) {
        return sendPost(httpUrl, postBody, "UTF-8", headerMap);
    }

    /**
     * 使用HTTP POST 发送文本
     *
     * @param httpUrl   发送的地址
     * @param postBody  发送的内容
     * @param encoding  发送的内容的编码
     * @param headerMap 增加的Http头信息
     * @return 返回HTTP SERVER的处理结果,如果返回null,发送失败
     */
    public static String sendPost(String httpUrl, String postBody, String encoding, Map<String, String> headerMap) {
        HttpURLConnection httpCon = null;
        String responseBody = null;
        URL url = null;
        try {
            url = new URL(httpUrl);
        } catch (MalformedURLException e1) {
            LogUtil.error(e1);
            return null;
        }
        try {
            httpCon = (HttpURLConnection) url.openConnection();
        } catch (IOException e1) {
            LogUtil.error(e1);
            return null;
        }
        if (httpCon == null) {
            LogUtil.error("openConnection null");
            return null;
        }
        httpCon.setDoOutput(true);
        httpCon.setConnectTimeout(TIME_OUT * 1000);
        httpCon.setReadTimeout(TIME_OUT * 1000);
        httpCon.setDoOutput(true);
        httpCon.setUseCaches(false);
        try {
            httpCon.setRequestMethod("POST");
        } catch (ProtocolException e1) {
            LogUtil.error(e1);
            return null;
        }
        if (headerMap != null) {
            Iterator<Entry<String, String>> iterator = headerMap.entrySet().iterator();
            while (iterator.hasNext()) {
                Entry<String, String> entry = iterator.next();
                httpCon.addRequestProperty(entry.getKey(), entry.getValue());
            }
        }
        OutputStream output;
        try {
            output = httpCon.getOutputStream();
        } catch (IOException e1) {
            LogUtil.error(e1);
            return null;
        }
        try {
            if (postBody != null) {
                output.write(postBody.getBytes(encoding));
            }
        } catch (UnsupportedEncodingException e1) {
            LogUtil.error(e1);
            return null;
        } catch (IOException e1) {
            LogUtil.error(e1);
            return null;
        }
        try {
            output.flush();
            output.close();
        } catch (IOException e1) {
            LogUtil.error(e1);
            return null;
        }
        // 开始读取返回的内容
        InputStream in;
        try {
            in = httpCon.getInputStream();
        } catch (IOException e1) {
            LogUtil.error(e1);
            return null;
        }

        int size = 0;
        try {
            size = in.available();
        } catch (IOException e1) {
            LogUtil.error(e1);
            return null;
        }
        if (size == 0) {
            size = 1024;
        }
        byte[] readByte = new byte[size];
        // 读取返回的内容
        int readCount = -1;
        try {
            readCount = in.read(readByte, 0, size);
        } catch (IOException e1) {
            LogUtil.error(e1);
            return null;
        }
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        while (readCount != -1) {
            baos.write(readByte, 0, readCount);
            try {
                readCount = in.read(readByte, 0, size);
            } catch (IOException e) {
                LogUtil.error(e);
                return null;
            }
        }
        try {
            responseBody = new String(baos.toByteArray(), encoding);
        } catch (UnsupportedEncodingException e) {
            LogUtil.error(e);
            return null;
        } finally {
            if (httpCon != null) {
                httpCon.disconnect();
            }
            if (baos != null) {
                try {
                    baos.close();
                } catch (IOException e) {
                    LogUtil.error(e);
                }
            }
        }
        return responseBody;
    }

    public static byte[] sendPbByte(String httpUrl, byte[] body) {
        HttpURLConnection httpCon = null;
        byte[] responseBody = null;
        URL url = null;
        try {
            url = new URL(httpUrl);
        } catch (MalformedURLException e1) {
            LogUtil.error(e1);
            return null;
        }
        try {
            httpCon = (HttpURLConnection) url.openConnection();
        } catch (IOException e1) {
            LogUtil.error(e1);
            return null;
        }
        if (httpCon == null) {
            LogUtil.error("openConnection null");
            return null;
        }
        httpCon.setDoOutput(true);
        httpCon.setConnectTimeout(TIME_OUT * 1000);
        httpCon.setReadTimeout(TIME_OUT * 1000);
        httpCon.setDoOutput(true);
        httpCon.setUseCaches(false);
        try {
            httpCon.setRequestMethod("POST");
        } catch (ProtocolException e1) {
            LogUtil.error(e1);
        }

        httpCon.addRequestProperty("Content-Type", "application/octet-stream");
        OutputStream output;
        try {
            output = httpCon.getOutputStream();
        } catch (IOException e1) {
            LogUtil.error("游戏服未连接上 查看端口和ip是否正确 httpUrl=" + httpUrl);
            return null;
        }
        try {
            if (body != null) {
                output.write(PbHelper.putShort((short) body.length));
                output.write(body);
            }
        } catch (UnsupportedEncodingException e1) {
            LogUtil.error(e1);
            return null;
        } catch (IOException e1) {
            LogUtil.error(e1);
            return null;
        }
        try {
            output.flush();
            output.close();
        } catch (IOException e1) {
            LogUtil.error(e1);
            return null;
        }
        // 开始读取返回的内容
        InputStream in;
        try {
            in = httpCon.getInputStream();
        } catch (IOException e1) {
            LogUtil.error(e1);
            return null;
        }

        int size = 0;
        try {
            size = in.available();
        } catch (IOException e1) {
            LogUtil.error(e1);
            return null;
        }
        if (size == 0) {
            size = 1024;
        }
        byte[] readByte = new byte[size];
        // 读取返回的内容
        int readCount = -1;
        try {
            readCount = in.read(readByte, 0, size);
        } catch (IOException e1) {
            LogUtil.error(e1);
            return null;
        }
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        while (readCount != -1) {
            baos.write(readByte, 0, readCount);
            try {
                readCount = in.read(readByte, 0, size);
            } catch (IOException e) {
                LogUtil.error(e);
                return null;
            }
        }
        try {
            responseBody = baos.toByteArray();
        } finally {
            if (httpCon != null) {
                httpCon.disconnect();
            }
            if (baos != null) {
                try {
                    baos.close();
                } catch (IOException e) {
                    LogUtil.error(e);
                }
            }
        }
        return responseBody;
    }
}