package com.hundredcent.game.aop;

/**
 * @author Tandonghai
 * @date 2018-01-09 11:52
 */
public final class AopConstant {


    private static boolean isCloseServer =false;

    /**
     * 时间单位转换：1分钟的秒数
     */
    public static final int MINUTE_SECONDS =  60;

    /**
     * 时间单位转换：一小时的秒数
     */
    public static final int HOUR_SECONDS = 60 * MINUTE_SECONDS;

    /**
     * 时间单位转换：一天的秒数
     */
    public static final int DAY_SECONDS = 24 * HOUR_SECONDS;

    /**
     * 时间单位转换：3天的秒数
     */
    public static final int THREE_SECONDS = 3 * DAY_SECONDS;

    /**
     * 时间单位转换：一天的秒数
     */
    public static final int WEEK_SECONDS = 7 * DAY_SECONDS;

    /**
     * 时间单位转换：一个月的秒数flushPlayerAddIdleSave
     */
    public static final int MONTH_SECONDS = 30 * DAY_SECONDS;


    public static boolean isIsCloseServer() {
        return isCloseServer;
    }

    public static void setIsCloseServer(boolean isCloseServer) {
        AopConstant.isCloseServer = isCloseServer;
    }
}
