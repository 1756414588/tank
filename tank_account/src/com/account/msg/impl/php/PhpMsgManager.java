package com.account.msg.impl.php;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Iterator;
import java.util.LinkedList;

import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import com.account.constant.PhpCallbackConst;

/**
 * @author ChenKui
 * @version 创建时间：2016-1-21 下午2:52:00
 * @declare
 */

public class PhpMsgManager {

    private static PhpMsgManager manager = null;
    private static long count = 0;

    private LinkedList<PhpCallBack> queue = new LinkedList<>();

    // 每隔10分钟,清理过期数据
    private LinkedList<JSONObject> msgQueue = new LinkedList<>();

    public static PhpMsgManager getInstance() {
        if (manager == null) {
            manager = new PhpMsgManager();
        }
        return manager;
    }

    public void dealMsg(String callback, JSONObject msg) {
        Iterator<PhpCallBack> it = queue.iterator();
        while (it.hasNext()) {
            PhpCallBack next = it.next();
            String s = next.getJsonCallback();
            if (callback.equals(s)) {
                HttpServletResponse response = next.getResponse();
                sendMsg(response, callback, msg);
                it.remove();
                break;
            }
        }
        clearExpire();
    }

    public void dealMultipleMsg(String callback, JSONArray msg) {
        Iterator<PhpCallBack> it = queue.iterator();
        while (it.hasNext()) {
            PhpCallBack next = it.next();
            String s = next.getJsonCallback();
            if (callback.equals(s)) {
                HttpServletResponse response = next.getResponse();
                sendMultiple(response, msg);
                it.remove();
                break;
            }
        }
        clearExpire();
    }

    /**
     * 返回单个json消息
     *
     * @param response
     * @param callback
     * @param msg
     */
    public void sendMsg(HttpServletResponse response, String callback, JSONObject msg) {
        response.setContentType(PhpCallbackConst.CONTENTTYPE);
        response.setCharacterEncoding(PhpCallbackConst.CHARACTER);
        response.setHeader(PhpCallbackConst.HEADER_KEY, PhpCallbackConst.HEADER_VALUE);
        PrintWriter out = null;
        try {
            StringBuffer sb = new StringBuffer();
            sb.append(callback);
            sb.append("(");
            sb.append(msg);
            sb.append(")");
            out = response.getWriter();
            out.print(sb.toString());
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            out.flush();
            out.close();
        }
    }

    /**
     * 发送消息给客户端
     *
     * @param response
     * @param msg
     */
    public void sendMsg(HttpServletResponse response, JSONObject msg) {
        response.setContentType(PhpCallbackConst.CONTENTTYPE);
        response.setCharacterEncoding(PhpCallbackConst.CHARACTER);
        response.setHeader(PhpCallbackConst.HEADER_KEY, PhpCallbackConst.HEADER_VALUE);
        PrintWriter out = null;
        try {
            out = response.getWriter();
            out.print(msg);
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            out.flush();
            out.close();
        }
    }

    /**
     * 发送消息给客户端
     *
     * @param response
     * @param msg
     */
    public void sendMsg(HttpServletResponse response, JSONArray msg) {
        response.setContentType(PhpCallbackConst.CONTENTTYPE);
        response.setCharacterEncoding(PhpCallbackConst.CHARACTER);
        response.setHeader(PhpCallbackConst.HEADER_KEY, PhpCallbackConst.HEADER_VALUE);
        PrintWriter out = null;
        try {
            out = response.getWriter();
            out.print(msg.toString());
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            out.flush();
            out.close();
        }
    }

    /**
     * 返回多个json消息
     *
     * @param response
     * @param callback
     * @param msg
     */
    public void sendMultiple(HttpServletResponse response, JSONArray msg) {
        response.setContentType(PhpCallbackConst.CONTENTTYPE);
        response.setCharacterEncoding(PhpCallbackConst.CHARACTER);
        response.setHeader(PhpCallbackConst.HEADER_KEY, PhpCallbackConst.HEADER_VALUE);
        PrintWriter out = null;
        try {
//			StringBuffer sb = new StringBuffer();
//			sb.append(msg);
            out = response.getWriter();
            out.print(msg);
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            out.flush();
            out.close();
        }
    }

    public void addWaitResponse(PhpCallBack e) {
        queue.add(e);
    }

    public void addMsg(String callBack, JSONObject json) {
        JSONObject msg = new JSONObject();
        msg.put(PhpCallbackConst.CODE_KEY, callBack);
        msg.put(PhpCallbackConst.EXPIRE_KEY, System.currentTimeMillis() + 5 * 60 * 1000);
        msg.put(PhpCallbackConst.MSG_KEY, json);
        msgQueue.add(msg);
    }

    public void addMultipleMsg(String callBack, JSONArray jsonArray) {
        JSONObject msg = new JSONObject();
        msg.put(PhpCallbackConst.CODE_KEY, callBack);
        msg.put(PhpCallbackConst.EXPIRE_KEY, System.currentTimeMillis() + 5 * 60 * 1000);
        msg.put(PhpCallbackConst.MSG_KEY, jsonArray);
        msgQueue.add(msg);
    }

    public JSONObject getMsg(String callback) {
        Iterator<JSONObject> it = msgQueue.iterator();
        while (it.hasNext()) {
            JSONObject en = it.next();
            if (en.getString(PhpCallbackConst.CODE_KEY).equals(callback)) {
                JSONObject msg = en.getJSONObject(PhpCallbackConst.MSG_KEY);
                it.remove();
                return msg;
            }
        }
        return null;
    }

    public JSONArray getMultipleMsg(String callback) {
        Iterator<JSONObject> it = msgQueue.iterator();
        while (it.hasNext()) {
            JSONObject en = it.next();
            if (en.getString(PhpCallbackConst.CODE_KEY).equals(callback)) {
                JSONArray msg = en.getJSONArray(PhpCallbackConst.MSG_KEY);
                it.remove();
                return msg;
            }
        }
        return null;
    }

    /**
     * 处理过期消息
     */
    public void clearExpire() {
        count++;
        if (count % 100 == 0) {
            Iterator<JSONObject> it = msgQueue.iterator();
            long currentTime = System.currentTimeMillis();
            while (it.hasNext()) {
                JSONObject msg = it.next();
                long expire = msg.getLong(PhpCallbackConst.EXPIRE_KEY);
                if (currentTime > expire) {
                    it.remove();
                }
            }
        }
    }
}
