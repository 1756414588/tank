package com.hundredcent.game.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author Tandonghai
 * @date 2018-01-22 13:27
 */
public class AgentLogUtil {
    private static final Logger SAVE_LOGGER = LoggerFactory.getLogger("SAVE");
    private static final Logger COMMON_LOGGER = LoggerFactory.getLogger("ERROR");

    public static void saveInfo(String message) {
        SAVE_LOGGER.info("[agent] " + getClassPath() + message);
    }

    public static void saveInfo(String message, Object... var2) {
        SAVE_LOGGER.info("[agent] " + getClassPath() + message, var2);
    }

    public static void debug(String message) {
        SAVE_LOGGER.debug("[agent] " + getClassPath() + message);
    }

    /**
     * 记录报错日志
     *
     * @param message
     * @param t
     */
    public static void error(Object message, Throwable t) {
        COMMON_LOGGER.error("[agent] " + getClassPath() + message, t);
    }


    /**
     * 记录报错日志
     *
     * @param message
     */
    public static void error(Object message) {
        if (message instanceof Throwable) {
            Throwable t = (Throwable) message;
            COMMON_LOGGER.error("[agent] " + getClassPath(), t);
        } else {
            COMMON_LOGGER.error("[agent] " + getClassPath() + message);
        }
    }

    /**
     * 调用的方法路径 从第三底层开始
     *
     * @return
     */
    private static String getClassPath() {
        StackTraceElement[] stackTraceElements = Thread.currentThread().getStackTrace();
        StackTraceElement ele = stackTraceElements[3];
        return getSimpleClassName(ele.getFileName()) + "." + ele.getMethodName() + "():" + ele.getLineNumber() + " - ";
    }

    /**
     * class名处理
     *
     * @param fileName
     * @return
     */
    public static String getSimpleClassName(String fileName) {
        int index = fileName.indexOf(".");
        if (index > 0) {
            return fileName.substring(0, index);
        }
        return fileName;
    }
}
