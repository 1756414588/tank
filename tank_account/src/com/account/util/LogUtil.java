package com.account.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author TanDonghai
 * @Description 日志工具类
 * @date 创建时间：2017年7月6日 下午6:38:35
 */
public class LogUtil {
    private static final Logger PAY_LOGGER = LoggerFactory.getLogger("payAppender");

    /**
     * 打印玩家充值日志
     *
     * @param message
     */
    public static void pay(Object message) {
        PAY_LOGGER.info(message.toString());
    }

    public static void test(Object message) {
        PAY_LOGGER.error(message.toString());
    }
}
