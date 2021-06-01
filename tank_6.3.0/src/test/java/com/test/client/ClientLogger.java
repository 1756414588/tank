package com.test.client;

import com.game.util.LogUtil;

import java.io.PrintWriter;
import java.io.StringWriter;

/**
 * @Description 客户端模拟日志打印助手
 * @author TanDonghai
 * @date 创建时间：2017年10月25日 下午6:49:31
 *
 */
public final class ClientLogger {
    private ClientLogger() {
    }

    public static void print(Object message) {
        LogUtil.info("[client] [" + Thread.currentThread().getName() + "] " + message);
    }

    public static void error(String message) {
        LogUtil.info("[error] [" + Thread.currentThread().getName() + "] " + message);
    }

    public static void error(Throwable t, String message) {
        String error = printStackTraceToString(t);
        LogUtil.info(String.format("[error] [%s] %s%n%s", Thread.currentThread().getName(), message, error));
    }

    public static String printStackTraceToString(Throwable t) {
        StringWriter sw = new StringWriter();
        t.printStackTrace(new PrintWriter(sw, true));
        return sw.getBuffer().toString();
    }
}
