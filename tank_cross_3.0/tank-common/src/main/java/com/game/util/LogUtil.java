package com.game.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LogUtil {

    private static Logger SAVE_LOGGER = LoggerFactory.getLogger("SAVE");
    private static Logger ERROR_LOGGER = LoggerFactory.getLogger("ERROR");
    private static Logger MESSAGE_LOGGER = LoggerFactory.getLogger("MESSAGE");
    private static Logger CROSS = LoggerFactory.getLogger("CROSS");


    /**
     * 报错记录日志
     *
     * @param message
     * @param t       void
     */
    public static void error(Object message, Throwable t) {
        ERROR_LOGGER.error(getClassPath() + message, t);
    }

    public static void error(String msg, Object... param) {
        ERROR_LOGGER.error(getClassPath() + msg, param);
    }

    public static void info(String msg, Object... param) {
        ERROR_LOGGER.info(getClassPath() + msg, param);
    }

    public static void crossInfo(String msg, Object... param) {
        CROSS.info(getClassPath() + msg, param);
    }

    /**
     * 报错记录日志
     *
     * @param message void
     */
    public static void error(Object message) {
        if (message instanceof Throwable) {
            Throwable t = (Throwable) message;
            ERROR_LOGGER.error(getClassPath(), t);
        } else {
            ERROR_LOGGER.error(getClassPath() + message);
        }
    }


    /**
     * 收到客户端消息
     *
     * @param message
     * @param roleId  void
     */
    public static void c2sReqMessage(Object message, Long roleId) {
        MESSAGE_LOGGER.info("[c2s] " + getClassPath() + "roleId:" + roleId + ", " + message);
    }

    /**
     * 发消息到客户端记录
     *
     * @param message
     * @param roleId  void
     */
    public static void c2sMessage(Object message, Long roleId) {
        MESSAGE_LOGGER.info("[c2s] " + getClassPath(6) + "roleId:" + roleId + ", " + message);
    }

    /**
     * 与跨服战通信消息记录
     *
     * @param message void
     */
    public static void s2sMessage(Object message) {
        MESSAGE_LOGGER.info("[s2s] " + getClassPath() + message);
    }
    /**
     * 与跨服战通信消息记录
     *
     * @param message void
     */
    public static void s2sRpcMessage(Object message) {
        MESSAGE_LOGGER.info("[rpc] " + getClassPath() +message.getClass().getSimpleName()+" "+ message);
    }

    /**
     * 保存数据到数据库
     *
     * @param message void
     */
    public static void save(Object message) {
        SAVE_LOGGER.info("[save] " + getClassPath() + message);
    }

    /**
     * 保存数据到数据库
     *
     * @param message void
     */
    public static void save(Object message, Object... param) {
        SAVE_LOGGER.info("[save] " + getClassPath() + message, param);
    }

    /**
     * 调用的方法路径 从第三底层开始
     *
     * @return String
     */
    private static String getClassPath() {
        StackTraceElement[] stackTraceElements = Thread.currentThread().getStackTrace();
        StackTraceElement ele = stackTraceElements[3];
        return getSimpleClassName(ele.getFileName()) + "." + ele.getMethodName() + "():" + ele.getLineNumber() + " - ";
    }


    /**
     * 调用的方法路径 从第stackIndex底层开始
     *
     * @param stackIndex
     * @return String
     */
    private static String getClassPath(int stackIndex) {
        StackTraceElement[] stackTraceElements = Thread.currentThread().getStackTrace();
        if (stackTraceElements.length <= stackIndex) {
            stackIndex = 3;
        }
        StackTraceElement ele = stackTraceElements[stackIndex];
        return getSimpleClassName(ele.getFileName()) + "." + ele.getMethodName() + "():" + ele.getLineNumber() + " - ";
    }

    /**
     * class名处理
     *
     * @param fileName
     * @return String
     */
    public static String getSimpleClassName(String fileName) {
        int index = fileName.indexOf(".");
        if (index > 0) {
            return fileName.substring(0, index);
        }
        return fileName;
    }


}
