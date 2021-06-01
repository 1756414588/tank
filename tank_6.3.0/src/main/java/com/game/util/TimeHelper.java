/**
 * @Title: TimeHelper.java
 * @Package com.game.util
 * @Description:
 * @author ZhangJun
 * @date 2015年8月12日 下午6:17:40
 * @version V1.0
 */
package com.game.util;

import com.game.constant.CrossConst;
import com.game.server.GameServer;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;

/**
 * @author ZhangJun
 * @ClassName: TimeHelper
 * @Description:
 * @date 2015年8月12日 下午6:17:40
 */
public class TimeHelper {
    final static public long SECOND_MS = 1000L;
    final static public long MINUTE_MS = 60 * 1000L;
    final static public long DAY_MS = 24 * 60 * 60 * 1000L;
    final static public int MINUTE_S = 60;
    final static public int DAY_S = 24 * 60 * 60;
    final static public int HOUR_S = 60 * 60;
    final static public int HALF_HOUR_S = 30 * 60;

    /**
     * 时间戳精确到秒
     *
     * @return int
     */
    public static int getCurrentSecond() {
        return (int) (System.currentTimeMillis() / SECOND_MS);
    }

    /**
     * 时间戳精确到分
     *
     * @return int
     */
    public static int getCurrentMinute() {
        return (int) (System.currentTimeMillis() / MINUTE_MS);
    }

    // public static int getCurrentDay() {
    // return (int) (System.currentTimeMillis() / DAY_MS);
    // }

    /**
     * 时间的月份和日期号数
     *
     * @return int[]
     */
    public static int[] getCurrentMonthAndDay() {
        Calendar c = Calendar.getInstance();
        return new int[]{c.get(Calendar.MONTH) + 1, c.get(Calendar.DAY_OF_MONTH)};
    }

    /**
     * 当天yyyyMMdd格式数字日期
     *
     * @return int
     */
    public static int getCurrentDay() {
        Calendar c = Calendar.getInstance();
        int d = c.get(Calendar.YEAR) * 10000 + (c.get(Calendar.MONTH) + 1) * 100 + c.get(Calendar.DAY_OF_MONTH);
        return d;
    }

    /**
     * yyyyww格式年份星期数
     *
     * @return int
     */
    public static int getCurrentWeek() {
        Calendar c = Calendar.getInstance();
        c.setFirstDayOfWeek(Calendar.MONDAY);
        int d = c.get(Calendar.YEAR) * 100 + c.get(Calendar.WEEK_OF_YEAR);
        return d;
    }

    /**
     * 当前几点钟
     *
     * @return int
     */
    public static int getCurrentHour() {
        Calendar c = Calendar.getInstance();
        return c.get(Calendar.HOUR_OF_DAY);
    }

    /**
     * @param time格式为20150108
     * @param passTime格式为20150108
     * @return
     */
    public static int subDay(int time, int passTime) {
        if (passTime == 0 || passTime == 0) {
            return 0;
        }
        long time1 = getDate(time).getTime();
        long time2 = getDate(passTime).getTime();
        return (int) ((time1 - time2) / (DAY_S * 1000));
    }

    /**
     * 把yyyyMMdd的数字型日期转成取当天凌晨的date
     *
     * @param today
     * @return Date
     */
    public static Date getDate(int today) {
        int passYear = today / 10000;
        if (passYear == 0) {
            return null;
        }
        int passMonth = (today - passYear * 10000) / 100;
        int passToday = (today - passYear * 10000 - passMonth * 100);
        String date = passYear + "-" + passMonth + "-" + passToday + " 00:00:00.000";
        Date d1 = DateHelper.parseDate(date);
        return d1;
    }

    /**
     * 判断星期一
     *
     * @return boolean
     */
    public static boolean isMonday() {
        Calendar calendar = Calendar.getInstance();
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
        if (dayOfWeek == 2) {
            return true;
        }
        return false;
    }

    /**
     * 判断星期二
     *
     * @return boolean
     */
    public static boolean isTuesday() {
        Calendar calendar = Calendar.getInstance();
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
        return dayOfWeek == Calendar.TUESDAY;
    }

    /**
     * 是否是星期dayOfWeek
     *
     * @param dayOfWeek
     * @return boolean
     */
    public static boolean isDayOfWeek(int dayOfWeek) {
        Calendar calendar = Calendar.getInstance();
        int weekDay = calendar.get(Calendar.DAY_OF_WEEK);
        return weekDay == dayOfWeek;
    }

    /**
     * 返回今天是星期几，按中国习惯，星期一返回1，星期天返回7
     *
     * @return
     */
    public static int getCNDayOfWeek() {
        Calendar calendar = Calendar.getInstance();
        int weekDay = calendar.get(Calendar.DAY_OF_WEEK) - 1;
        if (weekDay == 0) {
            weekDay = 7;
        }
        return weekDay;
    }

    /**
     * date转成yyyyMMdd格式数字日期
     *
     * @param date
     * @return int
     */
    public static int getDay(Date date) {
        Calendar c = Calendar.getInstance();
        c.setTime(date);
        return c.get(Calendar.YEAR) * 10000 + (c.get(Calendar.MONTH) + 1) * 100 + c.get(Calendar.DAY_OF_MONTH);
    }

    /**
     * 精确到秒的时间戳转成正常时间戳
     *
     * @param second
     * @return int
     */
    public static int getDay(long second) {
        return getDay(new Date(second * 1000));
        // Calendar c = Calendar.getInstance();
        // c.setTimeInMillis(second * 1000);
        // int d = c.get(Calendar.YEAR) * 10000 + (c.get(Calendar.MONTH) + 1) *
        // 100 + c.get(Calendar.DAY_OF_MONTH);
        // return d;
    }

    /**
     * 精确到秒的时间戳转成Date
     *
     * @param second
     * @return Date
     */
    public static Date getDate(long second) {
        return new Date(second * 1000);
    }

    /**
     * 得到一个MMdd00格式的数字
     *
     * @param date
     * @return int
     */
    public static int getMonthAndDay(Date date) {
        Calendar c = Calendar.getInstance();
        c.setTime(date);
        int monthAndDay = (c.get(Calendar.MONTH) + 1) * 10000 + (c.get(Calendar.DAY_OF_MONTH)) * 100;
        return monthAndDay;
    }

    /**
     * 当前时间是否是hour时minite分second秒 精确到秒
     *
     * @param hour
     * @param minute
     * @param second
     * @return boolean
     */
    public static boolean isTimeSecond(int hour, int minute, int second) {
        Calendar calendar = Calendar.getInstance();
        int h = calendar.get(Calendar.HOUR_OF_DAY);
        int m = calendar.get(Calendar.MINUTE);
        int s = calendar.get(Calendar.SECOND);
        return h == hour && m == minute && s == second;
    }

    /**
     * 当前时间是否是hour时minite分 精确到分
     *
     * @param hour
     * @param minute
     * @return boolean
     */
    public static boolean isTime(int hour, int minute) {
        Calendar calendar = Calendar.getInstance();
        int h = calendar.get(Calendar.HOUR_OF_DAY);
        int m = calendar.get(Calendar.MINUTE);
        return h == hour && m == minute;
    }

    /**
     * 设置指定的精确到秒的时间戳
     *
     * @param hour
     * @param minute
     * @param second
     * @return int
     */
    public static int getSecond(int hour, int minute, int second) {
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.HOUR_OF_DAY, hour);
        calendar.set(Calendar.MINUTE, minute);
        calendar.set(Calendar.SECOND, second);
        calendar.set(Calendar.MILLISECOND, 0);
        return (int) (calendar.getTimeInMillis() / 1000);
    }

    /**
     * 设置若干天后指定的精确到秒的时间戳
     *
     * @param addDays
     * @param hour
     * @param minute
     * @param second
     * @return int
     */
    public static int getSomeDayAfter(int addDays, int hour, int minute, int second) {
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.DAY_OF_YEAR, calendar.get(Calendar.DAY_OF_YEAR) + addDays);
        calendar.set(Calendar.HOUR_OF_DAY, hour);
        calendar.set(Calendar.MINUTE, minute);
        calendar.set(Calendar.SECOND, second);
        calendar.set(Calendar.MILLISECOND, 0);
        return (int) (calendar.getTimeInMillis() / 1000);
    }

    /**
     * 现在是几点
     *
     * @return int
     */
    public static int getHour() {
        Calendar calendar = Calendar.getInstance();
        return calendar.get(Calendar.HOUR_OF_DAY);
    }

    /**
     * 现在是几分
     *
     * @return int
     */
    public static int getMinute() {
        Calendar calendar = Calendar.getInstance();
        return calendar.get(Calendar.MINUTE);
    }

    /**
     * 获取下个小时的整点时间
     *
     * @return
     */
    public static int getNextHourTime() {
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.HOUR_OF_DAY, calendar.get(Calendar.HOUR_OF_DAY) + 1);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        return (int) (calendar.getTimeInMillis() / 1000);
    }

    /**
     * 获取离现在最近的整点时间，如果当前时间是整点，直接返回当前时间，否则返回下一个小时的整点时间
     *
     * @return
     */
    public static int getNearlyHourTime() {
        Calendar calendar = Calendar.getInstance();
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        int second = calendar.get(Calendar.SECOND);
        if (second != 0 || minute != 0) {
            calendar.set(Calendar.HOUR_OF_DAY, hour + 1);
            calendar.set(Calendar.MINUTE, 0);
            calendar.set(Calendar.SECOND, 0);
        }
        calendar.set(Calendar.MILLISECOND, 0);
        return (int) (calendar.getTimeInMillis() / 1000);
    }

    /**
     * 是否团战报名开启时间
     *
     * @return boolean
     */
    public static boolean isWarBeginReg() {
        Calendar calendar = Calendar.getInstance();
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        if (hour == 19 && minute == 30) {
            return true;
        }

        // if (hour == 15 && minute == 0) {
        // return true;
        // }

        return false;
    }

    /**
     * 是否是团战报名结束时间
     *
     * @return boolean
     */
    public static boolean isWarBeginEnd() {
        Calendar calendar = Calendar.getInstance();
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        if (hour == 19 && minute == 55) {
            return true;
        }

        // if (hour == 15 && minute == 30) {
        // return true;
        // }

        return false;
    }

    /**
     * 是否是团战战斗开始时间
     *
     * @return boolean
     */
    public static boolean isWarBeginFight() {
        Calendar calendar = Calendar.getInstance();
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        if (hour == 20 && minute == 0) {
            return true;
        }

        // if (hour == 16 && minute == 0) {
        // return true;
        // }

        return false;
    }

    /**
     * 当前是否是周一周三周六
     *
     * @return boolean
     */
    public static boolean isWarDay() {
        int day = DateHelper.dayiy(GameServer.getInstance().OPEN_DATE, new Date());
        if (day <= 7) {
            return false;
        }

        Calendar calendar = Calendar.getInstance();
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
        if (dayOfWeek == Calendar.MONDAY || dayOfWeek == Calendar.WEDNESDAY || dayOfWeek == Calendar.SATURDAY) {
            return true;
        }

        return false;

        // return true;
    }

    // /**
    // * 百团大战结算日(通过积分计算参加要塞战军团条件)
    // *
    // * @return
    // */
    // public static boolean isWarFortressCaluDay() {
    // Calendar calendar = Calendar.getInstance();
    // return calendar.get(Calendar.DAY_OF_WEEK) == Calendar.SATURDAY;
    // }

    /**
     * 周六23:00 计算可以参加要塞战的军团
     *
     * @return
     */
    public static boolean isCalCanJoinFortressTime() {
        int d = DateHelper.dayiy(GameServer.getInstance().OPEN_DATE, new Date());
        if (d <= 44) {
            return false;
        }

        Calendar calendar = Calendar.getInstance();

        int day = calendar.get(Calendar.DAY_OF_WEEK);
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        if (day == Calendar.SATURDAY && hour == 23 && minute == 00) {
            return true;
        }

        return false;
    }

    /**
     * 开服超过7天开启团战
     *
     * @return boolean
     */
    public static boolean isWarOpen() {
        int day = DateHelper.dayiy(GameServer.getInstance().OPEN_DATE, new Date());
        if (day <= 7) {
            return false;
        }

        return true;
    }

    /**
     * 世界boss开启时间 晚上8点50
     *
     * @return boolean
     */
    public static boolean isBossBegin() {
        Calendar calendar = Calendar.getInstance();
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        if (hour == 20 && minute == 50) {
            return true;
        }

        return false;
    }

    /**
     * 世界boss开始战斗时间 9点
     *
     * @return boolean
     */
    public static boolean isBossFightBegin() {
        Calendar calendar = Calendar.getInstance();
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        if (hour == 21 && minute == 0) {
            return true;
        }

        return false;
    }

    /**
     * boss战结束 9点30分
     *
     * @return boolean
     */
    public static boolean isBossFightEnd() {
        Calendar calendar = Calendar.getInstance();
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        if (hour == 21 && minute == 30) {
            return true;
        }

        return false;
    }

    /**
     * 开服30天后开启世界boss 每周5开启
     *
     * @return boolean
     */
    public static boolean isBossDay() {
        int day = DateHelper.dayiy(GameServer.getInstance().OPEN_DATE, new Date());
        if (day <= 30) {
            return false;
        }

        Calendar calendar = Calendar.getInstance();
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
        if (dayOfWeek == Calendar.FRIDAY) {
            return true;
        }

        return false;
    }

    /**
     * 开服30天后开启世界boss
     *
     * @return boolean
     */
    public static boolean isBossOpen() {
        int day = DateHelper.dayiy(GameServer.getInstance().OPEN_DATE, new Date());
        if (day <= 30) {
            return false;
        }

        return true;
    }

    /**
     * 开服30天后编制等级开启
     *
     * @return boolean
     */
    public static boolean isStaffingOpen() {
        int day = DateHelper.dayiy(GameServer.getInstance().OPEN_DATE, new Date());
        if (day <= 30) {
            return false;
        }

        return true;
    }

    /**
     * 开服45天后要塞战开启
     *
     * @return boolean
     */
    public static boolean isFortresssOpen() {
        int day = DateHelper.dayiy(GameServer.getInstance().OPEN_DATE, new Date());
        if (day <= 45) {
            return false;
        }

        return true;
    }

    /**
     * 获取当前日期的第二天凌晨时间
     *
     * @param date
     * @return
     */
    public static Date getSecondDayZeroTime(Date date) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.add(GregorianCalendar.DATE, 1);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        return cal.getTime();
    }

    /**
     * 获取当前日期凌晨时间
     *
     * @param date
     * @return Date
     */
    public static Date getDateZeroTime(Date date) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        return cal.getTime();
    }

    /**
     * 是否要塞开战日 Method: isFortressBattleDay
     *
     * @Description: @return @return boolean @throws
     */
    public static boolean isFortressBattleDay() {
        int day = DateHelper.dayiy(GameServer.getInstance().OPEN_DATE, new Date());
        if (day <= 45) {
            return false;
        }

        Calendar calendar = Calendar.getInstance();
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
        if (dayOfWeek == Calendar.SUNDAY) {
            return true;
        }

        return false;
    }

    /**
     * 要塞战预热 Method: isFortressBattlePrepare
     *
     * @Description: @return @return boolean @throws
     */
    public static boolean isFortressBattlePrepare() {
        Calendar calendar = Calendar.getInstance();
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        if (hour == 19 && minute == 30) {
            return true;
        }

        return false;
    }

    /**
     * 要塞战开战时间 Method: isFortressBattleBeginFight
     *
     * @Description: @return @return boolean @throws
     */
    public static boolean isFortressBattleBeginFight() {
        Calendar calendar = Calendar.getInstance();
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        if (hour == 20 && minute == 00) {
            return true;
        }

        return false;
    }

    /**
     * 要塞战结束时间 Method: isFortressBattleBeginEnd
     *
     * @Description: @return @return boolean @throws
     */
    public static boolean isFortressBattleEnd() {
        Calendar calendar = Calendar.getInstance();
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        if (hour == 20 && minute == 15) {
            return true;
        }

        return false;
    }

    /**
     * 清理要塞战职位
     *
     * @return
     */
    public static boolean isFortressClearJob() {
        int day = DateHelper.dayiy(GameServer.getInstance().OPEN_DATE, new Date());
        if (day <= 45) {
            return false;
        }

        Calendar calendar = Calendar.getInstance();
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        if (dayOfWeek == Calendar.SATURDAY && hour == 19 && minute == 30) {
            return true;
        }

        return false;
    }

    /**
     * 星期六结算可以参加要塞战
     *
     * @return
     */
    public static boolean isCalJoinFortressParty() {
        int day = DateHelper.dayiy(GameServer.getInstance().OPEN_DATE, new Date());
        if (day <= 44) {
            return false;
        }

        Calendar calendar = Calendar.getInstance();
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
        return (dayOfWeek == Calendar.SATURDAY);
    }

    /**
     * 周日20点15到周六19:30之间
     *
     * @return
     */
    public static boolean isThisWeekSaturday1930ToSunday2015() {
        Calendar c = Calendar.getInstance();

        // 判断今天是否周日
        c.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY); // 周日
        c.set(Calendar.HOUR_OF_DAY, 20);
        c.set(Calendar.MINUTE, 15);
        c.set(Calendar.SECOND, 0);
        int s1 = (int) (c.getTime().getTime() / SECOND_MS);

        // 本周六19.30
        c.set(Calendar.DAY_OF_WEEK, Calendar.SATURDAY); // 获取周六的
        c.set(Calendar.HOUR_OF_DAY, 19);
        c.set(Calendar.MINUTE, 30);
        c.set(Calendar.SECOND, 0);
        int s2 = (int) (c.getTime().getTime() / SECOND_MS);

        int cc = getCurrentSecond();

        return s1 <= cc && cc <= s2;
    }

    /**
     * 服务器时间处于周六23点-周日17.30之间,
     *
     * @return
     */
    public static boolean isThisWeekSaturday2300ToSunday1930() {
        Calendar c = Calendar.getInstance();
        c.setFirstDayOfWeek(Calendar.MONDAY);

        // 本周六23:00
        c.set(Calendar.DAY_OF_WEEK, Calendar.SATURDAY); // 获取周六的
        c.set(Calendar.HOUR_OF_DAY, 23);
        c.set(Calendar.MINUTE, 0);
        c.set(Calendar.SECOND, 0);
        int s2 = (int) (c.getTime().getTime() / SECOND_MS);

        // 周日19:30
        c.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY); // 周日
        c.set(Calendar.HOUR_OF_DAY, 19);
        c.set(Calendar.MINUTE, 30);
        c.set(Calendar.SECOND, 0);
        // c.set(Calendar.WEEK_OF_YEAR, c.get(Calendar.WEEK_OF_YEAR)+1);
        int s1 = (int) (c.getTime().getTime() / SECOND_MS);

        int cc = getCurrentSecond();

        return s2 <= cc && cc <= s1;
    }

    /**
     * 是否小于本周六19.30
     *
     * @return
     */
    public static boolean isLessThanThisWeekSaturday1930() {
        Calendar c = Calendar.getInstance();
        // 本周六19.30
        c.set(Calendar.DAY_OF_WEEK, Calendar.SATURDAY); // 获取周六的
        c.set(Calendar.HOUR_OF_DAY, 19);
        c.set(Calendar.MINUTE, 30);
        c.set(Calendar.SECOND, 0);
        int s = (int) (c.getTime().getTime() / SECOND_MS);
        int cc = getCurrentSecond();
        return cc < s;
    }

    /**
     * 当前时间是否大于今天的19:30
     *
     * @return
     */
    public static boolean isMoreThan1930() {
        Calendar c = Calendar.getInstance();
        c.set(Calendar.HOUR_OF_DAY, 19);
        c.set(Calendar.MINUTE, 30);
        c.set(Calendar.SECOND, 0);
        int s = (int) (c.getTime().getTime() / SECOND_MS);
        int cc = getCurrentSecond();
        return cc > s;
    }

    /**
     * 当前时间是否大于今天的13:00
     *
     * @return
     */
    public static boolean isMoreThan1300() {
        Calendar c = Calendar.getInstance();
        c.set(Calendar.HOUR_OF_DAY, 13);
        c.set(Calendar.MINUTE, 0);
        c.set(Calendar.SECOND, 0);
        int s = (int) (c.getTime().getTime() / SECOND_MS);
        int cc = getCurrentSecond();
        return cc > s;
    }

    /**
     * 当前时间是否大于今天的13:00
     *
     * @return
     */
    public static boolean isLessThan1200() {
        Calendar c = Calendar.getInstance();
        c.set(Calendar.HOUR_OF_DAY, 12);
        c.set(Calendar.MINUTE, 0);
        c.set(Calendar.SECOND, 0);
        int s = (int) (c.getTime().getTime() / SECOND_MS);
        int cc = getCurrentSecond();
        return s > cc;
    }

    /**
     * 获取该天的凌晨时刻（秒）
     *
     * @param currentSecond
     * @return
     */
    public static int getTodayZone(int currentSecond) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(currentSecond * 1000L);
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        return (int) (calendar.getTimeInMillis() / 1000);
    }

    /**
     * 当天凌晨精确到秒
     *
     * @return int
     */
    public static int getTodayZone() {
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        return (int) (calendar.getTimeInMillis() / 1000);
    }

    /**
     * 第二天凌晨精确到秒
     *
     * @return int
     */
    public static int getTomorrowZone() {
        return getTodayZone() + DAY_S;
    }

    /**
     * 判断时间是否本周 Method: isThisWeek
     *
     * @Description: @param dayTime @return @return boolean @throws
     */
    public static boolean isThisWeek(int dayTime) {
        Calendar c = Calendar.getInstance();

        // 判断是否周日
        int dayOfWeek = c.get(Calendar.DAY_OF_WEEK);

        if (dayOfWeek == Calendar.SUNDAY) {
            c.add(Calendar.WEEK_OF_YEAR, -1);
        }

        c.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY); // 获取本周一的
        int mondayTime = c.get(Calendar.YEAR) * 10000 + (c.get(Calendar.MONTH) + 1) * 100 + c.get(Calendar.DAY_OF_MONTH);

        c.add(Calendar.WEEK_OF_YEAR, 1);
        c.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY); // 获取本周日的
        int sundayTime = c.get(Calendar.YEAR) * 10000 + (c.get(Calendar.MONTH) + 1) * 100 + c.get(Calendar.DAY_OF_MONTH);

        return dayTime >= mondayTime && dayTime <= sundayTime;
    }

    /**
     * 判断是否周日
     *
     * @return
     */
    public static boolean isSunDay() {
        Calendar c = Calendar.getInstance();
        // 判断是否周日
        int dayOfWeek = c.get(Calendar.DAY_OF_WEEK);
        return dayOfWeek == Calendar.SUNDAY;
    }

    /**
     * 获取本周一 Method: getThisWeekMonday @Description: @return @return int @throws
     */
    public static int getThisWeekMonday() {
        // 判断若是星期天的话,则需要-1周
        Calendar c = Calendar.getInstance();
        int dayOfWeek = c.get(Calendar.DAY_OF_WEEK);

        if (dayOfWeek == Calendar.SUNDAY) {
            c.add(Calendar.WEEK_OF_YEAR, -1);
        }

        c.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY); // 获取本周一的
        return c.get(Calendar.YEAR) * 10000 + (c.get(Calendar.MONTH) + 1) * 100 + c.get(Calendar.DAY_OF_MONTH);
    }

    /**
     * 获取本周日 Method: getThisWeekSunday @Description: @return @return int @throws
     */
    public static int getThisWeekSunday() {
        Calendar c = Calendar.getInstance();
        int dayOfWeek = c.get(Calendar.DAY_OF_WEEK);

        if (dayOfWeek == Calendar.SUNDAY) {
        } else {
            c.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY); // 获取本周日的
            c.add(Calendar.WEEK_OF_YEAR, 1);
        }

        return c.get(Calendar.YEAR) * 10000 + (c.get(Calendar.MONTH) + 1) * 100 + c.get(Calendar.DAY_OF_MONTH);
    }


    /**
     * 跨服战是否已开启
     *
     * @param type
     * @return boolean
     */
    public static boolean isCrossOpen(int type) {
        // 获取跨服开始时间
        if ("".equals(GameServer.getInstance().crossBeginTime)) {
            return false;
        }

        if (GameServer.getInstance().crossType == type) {
            int day = DateHelper.dayiy(DateHelper.parseDate(GameServer.getInstance().crossBeginTime), new Date());

            if (type == CrossConst.CrossType) {
                if (day >= 1 && day <= CrossConst.CrossDayTime) {
                    return true;
                }
            } else if (type == CrossConst.CrossPartyType) {
                if (day >= 1 && day <= CrossConst.CrossPartyDayTime) {
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * 是否是指定活动boss时间
     *
     * @param time
     * @return boolean
     */
    public static boolean isActBossTime(List<List<Integer>> time) {
        Calendar calendar = Calendar.getInstance();
        int hour = calendar.get(Calendar.HOUR_OF_DAY);

        for (List<Integer> time1 : time) {
            if (hour >= time1.get(0) && hour < time1.get(1)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 下次飞艇开启时间
     *
     * @param afterDay
     * @return int
     */
    public static int getAirshipOpenTime(int afterDay) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime((Date) GameServer.getInstance().OPEN_DATE.clone());
        calendar.add(Calendar.DAY_OF_YEAR, afterDay);
        calendar.set(Calendar.HOUR_OF_DAY, 9);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        return (int) (calendar.getTimeInMillis() / 1000);
    }

    /**
     * 获取当前时间十天后的时间 int @throws
     */
    public static Date getAfter10Days(Date date) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.add(Calendar.DAY_OF_MONTH, 10);
        Date date2 = cal.getTime();
        return date2;
    }

    /**
     * 获取当前时间4天前的时间 int @throws
     */
    public static Date getBefore4Days(Date date) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.add(Calendar.DAY_OF_MONTH, -4);
        Date date2 = cal.getTime();
        return date2;
    }

    /**
     * 获取上周一的时间 int @throws
     */
    public static int getLastMonday(Date date) {
        Calendar c = Calendar.getInstance();
        c.setTime(date);
        c.add(Calendar.DAY_OF_MONTH, -7);
        return c.get(Calendar.YEAR) * 10000 + (c.get(Calendar.MONTH) + 1) * 100 + c.get(Calendar.DAY_OF_MONTH);
    }

    /**
     * 判断指定时间与当前时间是否在同一个月内
     *
     * @param time
     */
    public static boolean isSameMonth(long time) {
        Calendar c1 = Calendar.getInstance();
        Calendar c2 = Calendar.getInstance();
        c2.setTime(new Date(time));
        return c1.get(Calendar.MONTH) == c2.get(Calendar.MONTH);

    }

    public static boolean getDayOfZero() {
        Calendar c = Calendar.getInstance();

        int hour = c.get(Calendar.HOUR_OF_DAY);
        int min = c.get(Calendar.MINUTE);
        int second = c.get(Calendar.SECOND);

        return hour == 0 && min == 0 && second < 10;
    }

    public static Date getCurrentDate() {
        Calendar c = Calendar.getInstance();
        return c.getTime();
    }


    /**
     * 获取两个日期相差整数天 例如 2018-12-31 23:59:59 ，2019-01-01 00:00:00相差2天
     *
     * @param endTime   活动结束时间
     * @param startTime 开始时间
     * @return 会返回-负数
     * @throws ParseException
     */
    public static int daysOfTwo(long endTime, long startTime) throws ParseException {
        Calendar calendar2 = Calendar.getInstance();
        calendar2.setTimeInMillis(endTime);
        calendar2.add(Calendar.DAY_OF_YEAR, 1);
        calendar2.set(Calendar.HOUR_OF_DAY, 0);
        calendar2.set(Calendar.MINUTE, 0);
        calendar2.set(Calendar.SECOND, 0);

        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(startTime);
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        return (int) ((calendar2.getTimeInMillis() - calendar.getTimeInMillis()) / 86400000L);
    }

    public static void main(String[] s) throws ParseException {


        Date parse = new SimpleDateFormat("yyyy-MM-dd").parse("2019-01-09 23:59:59");
        Date parse2 = new SimpleDateFormat("yyyy-MM-dd").parse("2019-01-04 00:00:00");

        //LogUtil.info(daysOfTwo(System.currentTimeMillis(), parse2.getTime()));


    }
}
