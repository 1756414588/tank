package com.account.util;

import java.io.*;
import java.net.*;
import java.util.Map;
import java.util.Set;

import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import com.account.handle.MessageHandle;
import com.game.pb.BasePb.Base;
import com.google.protobuf.InvalidProtocolBufferException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HttpHelper {
    public static Logger LOG = LoggerFactory.getLogger(HttpHelper.class);

    public static final String UTF8_ENCODE = "UTF-8";
    public static final ContentType CONTENT_TYPE = ContentType.create("text/plain", "UTF-8");
    private static final int TIME_OUT = 10;

    public static String doPost(String url, Map<String, String> param) throws Exception {

        StringBuilder sb = new StringBuilder();
        for (String k : param.keySet()) {
            sb.append(k);
            sb.append("=");
            sb.append(param.get(k));
            sb.append("&");
        }
        String paramStr = sb.substring(0, sb.length() - 1);
        LOG.error(url + "?" + paramStr);
        return doPost(url, paramStr);

    }

    public static String doPost(String url, String body) throws Exception {

        return doPost(url, body, null);
    }

    public static String doPost(String url, String body, Map<String, String> header) throws Exception {
        String responseBody = null;
        CloseableHttpClient httpclient = HttpClients.createDefault();
        try {
            HttpPost httpPost = new HttpPost(url);
            httpPost.setEntity(new StringEntity(body, CONTENT_TYPE));

            if (header != null && !header.isEmpty()) {
                for (Map.Entry<String, String> en : header.entrySet()) {
                    httpPost.addHeader(en.getKey(), en.getValue());
                }
            }
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

    public static Base sendMsgToGame(String url, Base msg) throws InvalidProtocolBufferException {
        byte[] result = sendPbByte(url, msg.toByteArray());

        short len = PbHelper.getShort(result, 0);
        // LOG.error("back len:" + len);
        byte[] data = new byte[len];
        System.arraycopy(result, 2, data, 0, len);

        Base rs = Base.parseFrom(data, MessageHandle.PB_EXTENDSION_REGISTRY);
        return rs;
    }

    public static Base sendMailMsgToGame(String url, Base msg) {
        try {
            byte[] result = sendPbByte(url, msg.toByteArray());

            short len = PbHelper.getShort(result, 0);
            // LOG.error("back len:" + len);
            byte[] data = new byte[len];
            System.arraycopy(result, 2, data, 0, len);
            Base rs = Base.parseFrom(data, MessageHandle.PB_EXTENDSION_REGISTRY);
            return rs;
        } catch (InvalidProtocolBufferException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return null;
    }

    public static byte[] sendPbByte(String httpUrl, byte[] body) {
        HttpURLConnection httpCon = null;
        byte[] responseBody = null;
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

        // if (headerMap != null) {
        // Iterator<Entry<String, String>> iterator =
        // headerMap.entrySet().iterator();
        // while (iterator.hasNext()) {
        // Entry<String, String> entry = iterator.next();
        // httpCon.addRequestProperty(entry.getKey(), entry.getValue());
        // }
        // }

        // httpCon.addRequestProperty("Content-Type",
        // "application/octet-stream");

        OutputStream output;
        try {
            output = httpCon.getOutputStream();
        } catch (IOException e1) {
            e1.printStackTrace();
            return null;
        }

        try {
            if (body != null) {
                // LOG.error("send byte lenth:" + body.length);
                output.write(PbHelper.putShort((short) body.length));

                // LOG.error("head:" +
                // Arrays.toString(PbHelper.putShort((short) body.length)));
                output.write(body);
                // LOG.error("body:" + Arrays.toString(body));
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
         * 这个方法可以在读写操作前先得知数据流里有多少个字节可以读取。 需要注意的是，如果这个方法用在从本地文件读取数据时，一般不会遇到问题，
         * 但如果是用于网络操作，就经常会遇到一些麻烦。
         * 比如，Socket通讯时，对方明明发来了1000个字节，但是自己的程序调用available()方法却只得到900，或者100，甚至是0，
         * 感觉有点莫名其妙，怎么也找不到原因。 其实，这是因为网络通讯往往是间断性的，一串字节往往分几批进行发送。
         * 本地程序调用available()方法有时得到0，这可能是对方还没有响应，也可能是对方已经响应了，但是数据还没有送达本地。
         * 对方发送了1000个字节给你，也许分成3批到达，这你就要调用3次available()方法才能将数据总数全部得到。
         *
         * 经常出现size为0的情况，导致下面readCount为0使之死循环(while (readCount != -1)
         * {xxxx})，出现死机问题
         */
        int size = 0;
        try {
            size = in.available();
        } catch (IOException e1) {
            e1.printStackTrace();
            return null;
        }

        LOG.error("back stream len:" + size);
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
            responseBody = baos.toByteArray();
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


    /**
     * 获取远程文本文件内容
     *
     * @param destUrl  远程Url
     * @param fileName 远程文件名
     * @param timeout  连接超时时间
     * @return
     */
    public static String requestRemoteFileData(String destUrl, String fileName, int timeout) {
        HttpURLConnection connection = null;
        BufferedReader reader = null;
        try {
            URL url = new URL(destUrl + fileName);
            connection = (HttpURLConnection) url.openConnection();
            connection.setConnectTimeout(timeout);
            connection.connect();
            if (connection.getResponseCode() == HttpURLConnection.HTTP_OK) {
                StringBuilder builder = new StringBuilder();
                reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));

                String lineStr = null;
                while ((lineStr = reader.readLine()) != null) {
                    builder.append(lineStr);
                }
                return builder.toString();
            }

        } catch (SocketTimeoutException e) {
            e.printStackTrace();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (ConnectException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (connection != null) {
                connection.disconnect();
                connection = null;
            }
        }
        return null;
    }
}
