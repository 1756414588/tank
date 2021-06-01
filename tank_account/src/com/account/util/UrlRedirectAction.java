package com.account.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import javax.servlet.ServletInputStream;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


public class UrlRedirectAction {

    public static Logger LOG = LoggerFactory.getLogger(UrlRedirectAction.class);

    private static final int BUFFER_SIZE = 32 * 1024;

    public static void redirectUrl(HttpServletRequest request, HttpServletResponse response) {

        //请求地址
        StringBuffer url = request.getRequestURL();
        LOG.error("[UrlRedirectAction] url : " + url.toString());
        //GET请求后面的参数
        String queryString = request.getQueryString();
        LOG.error("[UrlRedirectAction] queryString: " + queryString);
        //请求头
        String contentType = request.getContentType();
        LOG.error("[UrlRedirectAction] ContentType: " + contentType);
        //请求方法
        String method = request.getMethod();
        LOG.error("[UrlRedirectAction] method: " + method);

        if ("GET".equalsIgnoreCase(method)) {
            try {
                SimpleHTTPResult ret = simpleInvoke(method, appendUrl("http://sync.imooffice.cn:81/cb/oppo/01839DF298B1ACDB/sync.html", queryString), contentType, null);
                if (ret.code == 200) {
                    writerResponse(response, ret.data);
                } else {
                    response.setStatus(ret.code);
                }
            } catch (IOException e) {
                e.printStackTrace();
                response.setStatus(500);
            }
        } else {
            byte[] bodyData = getBodyData(request);
            SimpleHTTPResult ret;
            try {
                LOG.error("[UrlRedirectAction] POST data: " + new String(bodyData, "UTF-8"));
                ret = simpleInvoke(method, appendUrl("http://sync.imooffice.cn:81/cb/oppo/01839DF298B1ACDB/sync.html", queryString), contentType, bodyData);
                if (ret.code == 200) {
                    writerResponse(response, ret.data);
                } else {
                    response.setStatus(ret.code);
                }
            } catch (IOException e) {
                e.printStackTrace();
                response.setStatus(500);
            }
        }

    }

    //POST请求,读取参数
    private static byte[] getBodyData(HttpServletRequest request) {
        try {
            ServletInputStream input = request.getInputStream();
            int ctLength = request.getContentLength();
            if (ctLength >= 0) {
                byte[] b = new byte[ctLength];
                int len = 0;
                while (len < ctLength) {
                    int r = input.read(b, len, ctLength - len);
                    if (r < 0)
                        throw new IOException("?EOF");
                    len += r;
                }
                return b;
            } else {
                ByteArrayOutputStream bao = new ByteArrayOutputStream(BUFFER_SIZE);
                byte[] b = new byte[BUFFER_SIZE];
                int len = 0;
                while ((len = input.read(b)) > 0) {
                    bao.write(b, 0, len);
                }
                return bao.toByteArray();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    //返回
    private static void writerResponse(HttpServletResponse response, byte[] data) {
        ServletOutputStream outputStream = null;
        try {
            outputStream = response.getOutputStream();
            outputStream.write(data);

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (outputStream != null) {
                try {
                    outputStream.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private static String appendUrl(String toUrl, String queryString) {
        String url = "";
        if (toUrl.indexOf("?") > 0) {
            url = toUrl + "&" + queryString;
        } else {
            url = toUrl + "?" + queryString;
        }

        return url;
    }


    //封装http请求
    public static class SimpleHTTPResult {
        public int code;
        public byte[] data;
    }

    public static SimpleHTTPResult simpleInvoke(String method, String url, String contentType, byte[] outdata) throws IOException {
        SimpleHTTPResult res = new SimpleHTTPResult();
        HttpURLConnection http = (HttpURLConnection) (new URL(url)).openConnection();
        http.setRequestMethod(method);
        if (contentType != null)
            http.setRequestProperty("Content-Type", contentType);
        if (outdata != null) {
            http.setRequestProperty("Content-Length", Integer.toString(outdata.length));
        }
        http.setDoOutput(outdata != null ? true : false);
        http.setDoInput(true);
        http.setConnectTimeout(2 * 60 * 1000);
        http.setReadTimeout(2 * 60 * 1000);
        http.connect();
        if (outdata != null) {
            OutputStream outs = http.getOutputStream();
            outs.write(outdata);
            outs.close();
        }
        res.code = http.getResponseCode();
        if (res.code == 404) {
            return res;
        }
        InputStream stream = http.getInputStream();
        try {
            int len = http.getContentLength();
            byte[] data;
            if (len >= 0) {
                data = new byte[len];
                int off = 0;
                while (off < len) {
                    int read = stream.read(data, off, len - off);
                    if (read < 0)
                        throw new IOException();
                    off += read;
                }
            } else {
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                byte[] buffer = new byte[4096];
                for (; ; ) {
                    int read = stream.read(buffer, 0, buffer.length);
                    if (read < 0)
                        break;
                    baos.write(buffer, 0, read);
                }
                baos.close();
                data = baos.toByteArray();
            }
            res.data = data;
        } finally {
            stream.close();
        }
        return res;
    }

}
