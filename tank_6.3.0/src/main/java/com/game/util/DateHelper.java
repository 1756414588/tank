package com.game.util;

import com.game.common.ServerSetting;
import com.game.server.GameServer;
import org.apache.commons.lang3.time.DateUtils;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

/**
 * 日期工具类
 *
 * @author
 * @ClassName: DateHelper
 * @Description: TODO
 */
public class DateHelper {
    public static final String format1 = "yyyy-MM-dd HH:mm:ss";
    public static final String format2 = "yyyy-MM-dd";
    public static final String format3 = "yyyy-MM-dd HH:mm:ss.SSS";
    public static SimpleDateFormat dateFormat1 = new SimpleDateFormat(format1);
    public static SimpleDateFormat dateFormat2 = new SimpleDateFormat(format2);
    public static SimpleDateFormat dateFormat3 = new SimpleDateFormat(format3);

    static public boolean isSameDate(Date date1, Date date2) {
        if (date1 == null || date2 == null) {
            return false;
        }
        return DateUtils.isSameDay(date1, date2);
    }

    /**
     * 是否是同一天
     *
     * @param cal1
     * @param cal2
     * @return boolean
     */
    static public boolean isSameDate(Calendar cal1, Calendar cal2) {
        return DateUtils.isSameDay(cal1, cal2);
    }

    /**
     * @param cal1
     * @return boolean
     */
    static public boolean isBeforeOneDay(Calendar cal1) {
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.DATE, -1);
        return DateUtils.isSameDay(cal1, calendar);
    }

    /**
     * 是否是今天
     *
     * @param date
     * @return boolean
     */
    static public boolean isToday(Date date) {
        return DateUtils.isSameDay(date, new Date());
    }

    static public String displayDateTime() {
        return dateFormat3.format(new Date());
    }

    static public int getNowMonth() {
        Calendar calendar = Calendar.getInstance();
        return calendar.get(Calendar.MONTH + 1);
    }

    static public String displayNowDateTime() {
        return dateFormat1.format(new Date());
    }

    static public String formatDateTime(Date date, String format) {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(format);
        return simpleDateFormat.format(date);
    }

    static public String formatDateMiniTime(Date date) {
        return dateFormat3.format(date);
    }

    static public Date getInitDate() {
        Calendar calendar = Calendar.getInstance();
        calendar.set(2008, 1, 1);
        return calendar.getTime();
    }

    static public long getServerTime() {
        return Calendar.getInstance().getTime().getTime() / 1000;
    }

    static public long dvalue(Calendar calendar, Date date) {
        if (date == null || calendar == null) {
            return 0;
        }
        long dvalue = (calendar.getTimeInMillis() - date.getTime()) / 1000;
        return dvalue;
    }

    // cdTime --秒数
    static public boolean isOutCdTime(Date date, long cdTime) {
        Date nowDate = new Date();
        return (nowDate.getTime() - date.getTime()) > cdTime * 1000;
    }

    static public Date parseDate(String dateString) {
        try {
            return dateFormat1.parse(dateString);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return null;
    }

    static public boolean isInTime(Date now, Date begin, Date end) {
        if (now.before(end) && now.after(begin)) {
            return true;
        }

        return false;
    }

    /**
     * 第几天,同一天为第一天
     *
     * @param origin
     * @param now
     * @return
     */
    static public int dayiy(Date origin, Date now) {
        Calendar orignC = Calendar.getInstance();
        Calendar calendar = Calendar.getInstance();
        orignC.setTime(origin);
        orignC.set(Calendar.HOUR_OF_DAY, 0);
        orignC.set(Calendar.MINUTE, 0);
        orignC.set(Calendar.SECOND, 0);
        orignC.set(Calendar.MILLISECOND, 0);

        calendar.setTime(now);
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);

        return (int) ((calendar.getTimeInMillis() - orignC.getTimeInMillis()) / (24 * 3600 * 1000)) + 1;
    }

    /**
     * 获取当前是服务器开发第几周，开服第1天开始为第1周，第8天为第2周
     *
     * @return
     */
    public static int getServerOpenWeek() {
        return ((getServerOpenDay() - 1) / 7) + 1;
    }

    /**
     * 获取当前是服务器开发第几天，开服当天为第一天
     *
     * @return
     */
    public static int getServerOpenDay() {
        String openTime = GameServer.ac.getBean(ServerSetting.class).getOpenTime();
        Date openDate = parseDate(openTime);

        return dayiy(openDate, new Date());
    }

    public static int getServerOpenDay(long time) {
        String openTime = GameServer.ac.getBean(ServerSetting.class).getOpenTime();
        Date openDate = parseDate(openTime);

        return dayiy(openDate, new Date(time));
    }

    public static int getServerOpenWeek(long time) {
        return ((getServerOpenDay(time) - 1) / 7) + 1;
    }

    /**
     * 获取当前是今年的第几个星期
     * 周日算一个星期的第一天
     */
    public static int getWeekOfYear() {
        Calendar cal = Calendar.getInstance();
        return cal.get(Calendar.WEEK_OF_YEAR);
    }

    /**
     * 获取某个时间点是今年的第几个星期
     * 周日算一个星期的第一天
     */
    public static int getWeekOfYear(long millis) {
        Calendar cal = Calendar.getInstance();
        cal.setTimeInMillis(millis);
        return cal.get(Calendar.WEEK_OF_YEAR);
    }

    /**
     * 获取某个时间点是今年的第几个星期
     * 以我国方式，周一算一周第一天
     */
    public static int getWeekOfYearCN(long millis) {
        Calendar cal = Calendar.getInstance();
        cal.setTimeInMillis(millis);
        int WEEK_OF_YEAR = cal.get(Calendar.WEEK_OF_YEAR);
        int DAY_OF_WEEK = cal.get(Calendar.DAY_OF_WEEK);
        if (DAY_OF_WEEK == 1 && WEEK_OF_YEAR != 1) {
            return WEEK_OF_YEAR - 1;
        }
        return WEEK_OF_YEAR;
    }

    /**
     * 获取当前是今年的第几个星期
     * 以我国方式，周一算一周第一天
     */
    public static int getWeekOfYearCN() {
        Calendar cal = Calendar.getInstance();
        int WEEK_OF_YEAR = cal.get(Calendar.WEEK_OF_YEAR);
        int DAY_OF_WEEK = cal.get(Calendar.DAY_OF_WEEK);
        if (DAY_OF_WEEK == 1 && WEEK_OF_YEAR != 1) {
            return WEEK_OF_YEAR - 1;
        }
        return WEEK_OF_YEAR;
    }

    /**
     * 判断两个时间是否在同一周
     */
    public static boolean isInSameWeek(long time1, long time2) {
        return getWeekOfYear(time1) == getWeekOfYear(time2);
    }

    /**
     * 获取传入秒的当前天0点date对象
     */
    public static Date getTimeZoneDate(int currentSecond) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(currentSecond * 1000L);
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        return calendar.getTime();
    }


    /**
     * 以自定义的时间分隔点 判断是否是同一周
     *
     * @param timeStr （2|00:00 以每周2 00:00作为分隔点）
     * @param time    （需要判别的时间）
     * @return 同一周 返回true
     */
    public static boolean tsToWeek(String timeStr, long time) {
        long[] times = getTimes(timeStr, time);
        long now = System.currentTimeMillis();
        return now >= times[0] && now <= times[1];
    }

    /**
     * 自定义时间分隔点 获取该分隔点的开启和结束时间
     *
     * @param sj   （2|00:00 以每周2 00:00作为分隔点）
     * @param time [startTime,endTime]
     * @return
     */
    public static long[] getTimes(String sj, long time) {
        // 2|00:00
        String[] str = sj.split("\\|");
        String[] hours = str[1].split(":");

        int configWeek = Integer.valueOf(str[0]) + 1, configHour = Integer.valueOf(hours[0]), configMinute = Integer.valueOf(hours[1]);
        if (configWeek >= 8) {
            configWeek = 1;
        }

        long startTime = 0, endTime = 0;

        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(time);
        int nowWeek = calendar.get(Calendar.DAY_OF_WEEK);

        String timeStr = formatTime(calendar.getTimeInMillis(), "HH:mm");

        if (nowWeek > configWeek || (nowWeek == configWeek && compare(timeStr, str[1]))) {
            calendar.add(Calendar.WEEK_OF_YEAR, 1);
        }
        calendar.set(Calendar.DAY_OF_WEEK, configWeek);
        calendar.set(Calendar.HOUR_OF_DAY, configHour);
        calendar.set(Calendar.MINUTE, configMinute);
        calendar.set(Calendar.SECOND, 0);

        endTime = calendar.getTimeInMillis();

        Calendar calendar2 = Calendar.getInstance();
        calendar2.setTimeInMillis(calendar.getTimeInMillis() - 7 * 24 * 60 * 60 * 1000 + 1000);
        startTime = calendar2.getTimeInMillis();

        return new long[]{startTime, endTime};
    }

    private static boolean compare(String args1, String args2) {
        String[] args1Array = args1.split(":");
        String[] args2Array = args2.split(":");

        int i1 = Integer.valueOf(args1Array[0]);
        int i2 = Integer.valueOf(args1Array[1]);

        int i3 = Integer.valueOf(args2Array[0]);
        int i4 = Integer.valueOf(args2Array[1]);

        if ((i1 > i3) || (i1 == i3 && i2 >= i4)) {
            return true;
        }
        return false;
    }


    /**
     * long 形式的时间转换为时间字符串
     *
     * @param time1
     * @param pattern 时间格式
     * @return
     */
    public static String formatTime(long time1, String pattern) {
        DateFormat df = new SimpleDateFormat(pattern);
        return df.format(new Date(time1));
    }


    static public String displayNowDateTime(Date date) {
        return dateFormat1.format(date);
    }

}
