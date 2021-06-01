package com.account.plat.impl.self.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

public class HttpUtils {


    public static Logger LOG = LoggerFactory.getLogger(HttpUtils.class);
    private static final int TIME_OUT = 15;

    public static String sendGet(String httpUrl, Map<String, String> parameter) {
        return sendGet(httpUrl, parameter, "text/plain;charset:utf-8");
    }

    /**
     * 通过HTTP GET 发送参数
     *
     * @param httpUrl
     * @param parameter
     * @param httpMethod
     */
    public static String sendGet(String httpUrl, Map<String, String> parameter, String contentType) {
        if (parameter == null || httpUrl == null) {
            return null;
        }

        StringBuilder sb = new StringBuilder();
        Iterator<Map.Entry<String, String>> iterator = parameter.entrySet().iterator();
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
            httpCon.addRequestProperty("Content-Type", contentType);
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
            LOG.error("sendGet exception", e);
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
        return sentPost(httpUrl, postBody, "UTF-8", null);
    }

    /**
     * 使用HTTP POST 发送文本
     *
     * @param httpUrl  发送的地址
     * @param postBody 发送的内容
     * @return 返回HTTP SERVER的处理结果,如果返回null,发送失败
     */
    public static String sentPost(String httpUrl, String postBody, String encoding) {
        return sentPost(httpUrl, postBody, encoding, null);
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
        return sentPost(httpUrl, postBody, "UTF-8", headerMap);
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
    public static String sentPost(String httpUrl, String postBody, String encoding, Map<String, String> headerMap) {
        HttpURLConnection httpCon = null;
        String responseBody = null;
        URL url = null;
        try {
            url = new URL(httpUrl);
        } catch (MalformedURLException e1) {
            LOG.error("URL null");
            e1.printStackTrace();
            return null;
        }
        try {
            httpCon = (HttpURLConnection) url.openConnection();
        } catch (IOException e1) {
            e1.printStackTrace();
            LOG.error("openConnection exception");
            return null;
        }
        if (httpCon == null) {
            LOG.error("openConnection null");
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
            e1.printStackTrace();
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
            e1.printStackTrace();
            return null;
        }
        try {
            if (postBody != null) {
                output.write(postBody.getBytes(encoding));
            }

        } catch (UnsupportedEncodingException e1) {
            e1.printStackTrace();
            return null;
        } catch (IOException e1) {
            e1.printStackTrace();
            return null;
        }
        try {
            output.flush();
            output.close();
        } catch (IOException e1) {
            e1.printStackTrace();
            return null;
        }

        // 开始读取返回的内容
        InputStream in;
        try {
            in = httpCon.getInputStream();
        } catch (IOException e1) {
            e1.printStackTrace();
            return null;
        }
        /**
         * 这个方法可以在读写操作前先得知数据流里有多少个字节可以读取。 需要注意的是，如果这个方法用在从本地文件读取数据时，一般不会遇到问题， 但如果是用于网络操作，就经常会遇到一些麻烦。
         * 比如，Socket通讯时，对方明明发来了1000个字节，但是自己的程序调用available()方法却只得到900，或者100，甚至是0， 感觉有点莫名其妙，怎么也找不到原因。
         * 其实，这是因为网络通讯往往是间断性的，一串字节往往分几批进行发送。 本地程序调用available()方法有时得到0，这可能是对方还没有响应，也可能是对方已经响应了，但是数据还没有送达本地。
         * 对方发送了1000个字节给你，也许分成3批到达，这你就要调用3次available()方法才能将数据总数全部得到。
         *
         * 经常出现size为0的情况，导致下面readCount为0使之死循环(while (readCount != -1) {xxxx})，出现死机问题
         */
        int size = 0;
        try {
            size = in.available();
        } catch (IOException e1) {
            e1.printStackTrace();
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
            e1.printStackTrace();
            return null;
        }
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        while (readCount != -1) {
            baos.write(readByte, 0, readCount);
            try {
                readCount = in.read(readByte, 0, size);
            } catch (IOException e) {
                e.printStackTrace();
                return null;
            }
        }
        try {
            responseBody = new String(baos.toByteArray(), encoding);
        } catch (UnsupportedEncodingException e) {
            return null;
        } finally {
            if (httpCon != null) {
                httpCon.disconnect();
            }
            if (baos != null) {
                try {
                    baos.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        return responseBody;
    }

    public static String sentGet(String httpUrl, String encoding, Map<String, String> headerMap) {
        HttpURLConnection httpCon = null;
        String responseBody = null;
        URL url = null;
        try {
            url = new URL(httpUrl);
        } catch (MalformedURLException e1) {
            LOG.error("URL null");
            e1.printStackTrace();
            return null;
        }
        try {
            httpCon = (HttpURLConnection) url.openConnection();
        } catch (IOException e1) {
            e1.printStackTrace();
            LOG.error("openConnection exception");
            return null;
        }
        if (httpCon == null) {
            LOG.error("openConnection null");
            return null;
        }
        httpCon.setDoOutput(true);
        httpCon.setConnectTimeout(TIME_OUT * 1000);
        httpCon.setReadTimeout(TIME_OUT * 1000);
        httpCon.setDoOutput(true);
        httpCon.setUseCaches(false);
        try {
            httpCon.setRequestMethod("GET");
        } catch (ProtocolException e1) {
            e1.printStackTrace();
            return null;
        }
        if (headerMap != null) {
            Iterator<Entry<String, String>> iterator = headerMap.entrySet().iterator();
            while (iterator.hasNext()) {
                Entry<String, String> entry = iterator.next();
                httpCon.addRequestProperty(entry.getKey(), entry.getValue());
            }
        }

        // 开始读取返回的内容
        InputStream in;
        try {
            in = httpCon.getInputStream();
        } catch (IOException e1) {
            e1.printStackTrace();
            return null;
        }
        /**
         * 这个方法可以在读写操作前先得知数据流里有多少个字节可以读取。 需要注意的是，如果这个方法用在从本地文件读取数据时，一般不会遇到问题， 但如果是用于网络操作，就经常会遇到一些麻烦。
         * 比如，Socket通讯时，对方明明发来了1000个字节，但是自己的程序调用available()方法却只得到900，或者100，甚至是0， 感觉有点莫名其妙，怎么也找不到原因。
         * 其实，这是因为网络通讯往往是间断性的，一串字节往往分几批进行发送。 本地程序调用available()方法有时得到0，这可能是对方还没有响应，也可能是对方已经响应了，但是数据还没有送达本地。
         * 对方发送了1000个字节给你，也许分成3批到达，这你就要调用3次available()方法才能将数据总数全部得到。
         *
         * 经常出现size为0的情况，导致下面readCount为0使之死循环(while (readCount != -1) {xxxx})，出现死机问题
         */
        int size = 0;
        try {
            size = in.available();
        } catch (IOException e1) {
            e1.printStackTrace();
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
            e1.printStackTrace();
            return null;
        }
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        while (readCount != -1) {
            baos.write(readByte, 0, readCount);
            try {
                readCount = in.read(readByte, 0, size);
            } catch (IOException e) {
                e.printStackTrace();
                return null;
            }
        }
        try {
            responseBody = new String(baos.toByteArray(), encoding);
        } catch (UnsupportedEncodingException e) {
            return null;
        } finally {
            if (httpCon != null) {
                httpCon.disconnect();
            }
            if (baos != null) {
                try {
                    baos.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        return responseBody;
    }

    public static String sendJsonPost(String urlPath, String Json) {
        // 创建连接
        URL url;
        try {
            url = new URL(urlPath);
        } catch (MalformedURLException e1) {
            LOG.error("URL null");
            e1.printStackTrace();
            return null;
        }
        HttpURLConnection connection;
        StringBuffer sbuffer = null;
        try {
            // 添加 请求内容
            connection = (HttpURLConnection) url.openConnection();
            // 设置http连接属性
            connection.setDoOutput(true);// http正文内，因此需要设为true, 默认情况下是false;
            connection.setDoInput(true);// 设置是否从httpUrlConnection读入，默认情况下是true;
            connection.setRequestMethod("POST"); // 可以根据需要 提交 GET、POST、DELETE、PUT等http提供的功能
            // connection.setUseCaches(false);//设置缓存，注意设置请求方法为post不能用缓存
            // connection.setInstanceFollowRedirects(true);

            connection.setRequestProperty("Host", "*******"); // 设置请 求的服务器网址，域名，例如***.**.***.***
            // connection.setRequestProperty("Content-Type", " application/json");//设定 请求格式 json，也可以设定xml格式的
            connection.setRequestProperty("Accept-Charset", "utf-8"); // 设置编码语言
            connection.setRequestProperty("X-Auth-Token", "token"); // 设置请求的token
            connection.setRequestProperty("Connection", "keep-alive"); // 设置连接的状态
            connection.setRequestProperty("Transfer-Encoding", "chunked");// 设置传输编码
            connection.setRequestProperty("Content-Length", Json.toString().getBytes().length + ""); // 设置文件请求的长度
            connection.setReadTimeout(10000);// 设置读取超时时间
            connection.setConnectTimeout(10000);// 设置连接超时时间
            connection.connect();
            OutputStream out = connection.getOutputStream();// 向对象输出流写出数据，这些数据将存到内存缓冲区中
            out.write(Json.toString().getBytes()); // out.write(new String("测试数据").getBytes()); //刷新对象输出流，将任何字节都写入潜在的流中
            out.flush();
            // 关闭流对象,此时，不能再向对象输出流写入任何数据，先前写入的数据存在于内存缓冲区中
            out.close();
            // 读取响应
            if (connection.getResponseCode() == 200) {
                // 从服务器获得一个输入流
                InputStreamReader inputStream = new InputStreamReader(connection.getInputStream());// 调用HttpURLConnection连接对象的getInputStream()函数,
                // 将内存缓冲区中封装好的完整的HTTP请求电文发送到服务端。
                BufferedReader reader = new BufferedReader(inputStream);
                String lines;
                sbuffer = new StringBuffer("");
                while ((lines = reader.readLine()) != null) {
                    lines = new String(lines.getBytes(), "utf-8");
                    sbuffer.append(lines);
                }
                reader.close();
            } else {
                LOG.error("请求失败" + connection.getResponseCode());
            }
            // 断开连接
            connection.disconnect();
            return sbuffer.toString();
        } catch (IOException e) {
            LOG.error("请求失败" + e.getMessage());
            return null;
        }
    }

}
