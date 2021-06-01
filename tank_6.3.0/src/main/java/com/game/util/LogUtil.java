package com.game.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author TanDonghai
 * @ClassName LogUtil.java
 * @Description 日志记录工具类
 * @date 创建时间：2016年9月2日 下午3:29:19
 */
public class LogUtil {

    private static Logger PAY_LOGGER = LoggerFactory.getLogger("PAY");
    private static Logger CHAT_LOGGER = LoggerFactory.getLogger("CHAT");
    private static Logger SAVE_LOGGER = LoggerFactory.getLogger("SAVE");
    private static Logger WARN_LOGGER = LoggerFactory.getLogger("WARN");
    private static Logger ERROR_LOGGER = LoggerFactory.getLogger("ERROR");
    private static Logger COMMON_LOGGER = LoggerFactory.getLogger("COMMON");
    private static Logger MESSAGE_LOGGER = LoggerFactory.getLogger("MESSAGE");
    private static Logger ACTIVITY_LOGGER = LoggerFactory.getLogger("ACTIVITY");
    private static Logger STATISTICS_LOGGER = LoggerFactory.getLogger("STATISTICS");
    private static Logger DATA_LOGGER = LoggerFactory.getLogger("DATA");
    private static Logger HOTFIX_LOGGER = LoggerFactory.getLogger("HOTFIX");
    private static Logger SERVERSTATUS_LOGGER = LoggerFactory.getLogger("SERVERSTATUS");
    public static Logger CROSS_LOGGER = LoggerFactory.getLogger("CROSS");


    public static void crossError(String msg, Object... param) {
        CROSS_LOGGER.error(getClassPath() + msg, param);
    }

    public static void crossInfo(String msg, Object... param) {
        CROSS_LOGGER.info(getClassPath() + msg, param);
    }


    /**
     * 报错记录日志
     *
     * @param message
     * @param t       void
     */
    public static void error(Object message, Throwable t) {
        String str = getClassPath() + message;
        ERROR_LOGGER.error("[error] " + str, t);
        SentryHelper.sendToSentry(t);
    }

    public static void error(String msg, Object... param) {
        ERROR_LOGGER.error(msg, param);
    }

    public static void info(String msg, Object... param) {
        ERROR_LOGGER.info(msg, param);
    }

    /**
     * 报错记录日志
     *
     * @param message void
     */
    public static void error(Object message) {
        if (message instanceof Throwable) {
            Throwable t = (Throwable) message;
            ERROR_LOGGER.error("[error] " + getClassPath(), t);
            SentryHelper.sendToSentry(t);
        } else {
            ERROR_LOGGER.error("[error] " + getClassPath() + message);
        }
    }

    /**
     * 启动服务
     *
     * @param message void
     */
    public static void start(Object message) {
        ERROR_LOGGER.info("[start] " + getClassPath() + message);
    }

    /**
     * 关闭服务
     *
     * @param message void
     */
    public static void stop(Object message,Object... var2) {
        ERROR_LOGGER.info("[stop] " + getClassPath() + message,var2);
    }

    /**
     * 严重警告 级别大于error
     *
     * @param message void
     */
    public static void warn(Object message) {
        WARN_LOGGER.error("[warn] " + getClassPath() + message);
        SentryHelper.sendToSentry(message.toString());
    }

    /**
     * 服务器状态信息打印
     *
     * @param message
     */
    public static void serverStatus(String message,Object... var2) {
        SERVERSTATUS_LOGGER.info(message,var2);
    }

    /**
     * 记录公共信息
     *
     * @param message void
     */
    public static void common(Object message) {
        COMMON_LOGGER.info("[common] " + getClassPath() + message);
    }

    /**
     * 记录boss信息
     *
     * @param message void
     */
    public static void boss(Object message) {
        COMMON_LOGGER.info("[boss] " + getClassPath() + message);
    }

    /**
     * 记录团战相关
     *
     * @param message void
     */
    public static void war(Object message) {
        COMMON_LOGGER.info("[war] " + getClassPath() + message);
    }

    /**
     * nettey通道异常记录
     *
     * @param message void
     */
    public static void channel(Object message) {
        STATISTICS_LOGGER.info("[channel] " + getClassPath() + message);
    }

    /**
     * nettey通道异常记录
     *
     * @param message
     * @param t       void
     */
    public static void channel(Object message, Throwable t) {
        STATISTICS_LOGGER.error("[channel] " + getClassPath() + message, t);
    }

    /**
     * 逻辑处理时间过长记录
     *
     * @param message void
     */
    public static void haust(Object message) {
        STATISTICS_LOGGER.info("[haust] " + getClassPath() + message);
    }

    /**
     * 服务器访问两记录
     *
     * @param message void
     */
    public static void flow(Object message, Object... var2) {
        STATISTICS_LOGGER.info("[flow] " + message, var2);
    }

    /**
     * GM操作记录
     *
     * @param message void
     */
    public static void gm(Object message) {
        STATISTICS_LOGGER.info("[GM] " + getClassPath() + message);
    }

    /**
     * 禁言记录
     *
     * @param message void
     */
    public static void silence(Object message) {
        STATISTICS_LOGGER.info("[SILENCE] " + getClassPath() + message);
    }

    /**
     * 热更记录
     *
     * @param message void
     */
    public static void hotfix(Object message) {
        HOTFIX_LOGGER.info("[hotfix]" + getClassPath() + message);
    }

    /**
     * 热更报错
     *
     * @param message
     * @param t       void
     */
    public static void hotfix(Object message, Throwable t) {
        HOTFIX_LOGGER.error("[hotfix] " + getClassPath() + message, t);
        SentryHelper.sendToSentry(t);
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
     * 与账号服通信消息记录
     *
     * @param message void
     */
    public static void innerMessage(Object message) {
        MESSAGE_LOGGER.info("[inner] " + getClassPath() + message);
    }

    /**
     * 保存数据到数据库
     *
     * @param message void
     */
    public static void save(Object message, Object... var2) {
        SAVE_LOGGER.info("[save] " + getClassPath() + message,var2);
    }

    /**
     * 活动记录
     *
     * @param message void
     */
    public static void activity(Object message) {
        ACTIVITY_LOGGER.info("[activity] " + getClassPath() + message);
    }

    /**
     * 支付记录 暂时没用到
     *
     * @param message void
     */
    public static void pay(Object message) {
        PAY_LOGGER.info("[pay] " + getClassPath() + message);
    }

    /**
     * 世界频道聊天记录
     *
     * @param message void
     */
    public static void chat(String message) {
        CHAT_LOGGER.info(message);
    }

    /**
     * 记录统计信息
     *
     * @param message void
     */
    public static void statistics(String message) {
        DATA_LOGGER.info(message);
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

    /**
     * 普通信息打印
     *
     * @param message
     */
    public static void info(String message) {
        ERROR_LOGGER.info(message);
    }


}
