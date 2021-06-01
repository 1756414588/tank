package com.account.msg.impl.php;

import javax.servlet.http.HttpServletResponse;

/**
 * @author ChenKui
 * @version 创建时间：2016-1-21 下午12:00:12
 * @declare
 */

public class PhpCallBack {

    private HttpServletResponse response;
    private String jsonCallback;
    private long time;

    public PhpCallBack(HttpServletResponse response, String jsonCallback) {
        this.response = response;
        this.jsonCallback = jsonCallback;
        this.time = System.currentTimeMillis();
    }

    public String getJsonCallback() {
        return jsonCallback;
    }

    public void setJsonCallback(String jsonCallback) {
        this.jsonCallback = jsonCallback;
    }

    public long getTime() {
        return time;
    }

    public HttpServletResponse getResponse() {
        return response;
    }

    public void setResponse(HttpServletResponse response) {
        this.response = response;
    }
}
