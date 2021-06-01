/**
 * @Title: TimeHelper.java @Package com.game.util @Description: TODO
 * @author ZhangJun
 * @date 2015年8月12日 下午6:17:40
 * @version V1.0
 */
package com.game.util;

import com.game.constant.CrossPartyConst;
import com.game.server.GameContext;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

/**
 * @author ZhangJun
 * @ClassName: TimeHelper @Description: TODO
 * @date 2015年8月12日 下午6:17:40
 */
public class TimeHelper {
    public static final long SECOND_MS = 1000L;
    public static final long MINUTE_MS = 60 * 1000L;
    public static final int DAY_S = 24 * 60 * 60;
    public static final int HOUR_S = 60 * 60;
    public static final int HALF_HOUR_S = 30 * 60;

    public static final String FORMART = "yyyy-MM-dd HH:mm:ss.SSS";

    /**
     * long形式的时间转换为时间字符串
     *
     * @param time1
     * @param pattern 时间格式
     * @return
     */
    public static String formatTime(long time1, String pattern) {
        DateFormat df = new SimpleDateFormat(pattern);
        return df.format(time1);
    }

    public static int getCurrentSecond() {
        return (int) (System.currentTimeMillis() / SECOND_MS);
    }

    public static int getCurrentMinute() {
        return (int) (System.currentTimeMillis() / MINUTE_MS);
    }

    // public static int getCurrentDay() {
    // return (int) (System.currentTimeMillis() / DAY_MS);
    // }
    public static int getCurrentDay() {
        Calendar c = Calendar.getInstance();
        int d = c.get(Calendar.YEAR) * 10000 + (c.get(Calendar.MONTH) + 1) * 100 + c.get(Calendar.DAY_OF_MONTH);
        return d;
    }

    public static int getCurrentWeek() {
        Calendar c = Calendar.getInstance();
        c.setFirstDayOfWeek(Calendar.MONDAY);
        int d = c.get(Calendar.YEAR) * 100 + c.get(Calendar.WEEK_OF_YEAR);
        return d;
    }

    /**
     * @param time     格式为20150108
     * @param passTime 格式为20150108
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

    public static boolean isMonday() {
        Calendar calendar = Calendar.getInstance();
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
        if (dayOfWeek == 2) {
            return true;
        }
        return false;
    }

    public static int getDay(Date date) {
        Calendar c = Calendar.getInstance();
        c.setTime(date);
        int d = c.get(Calendar.YEAR) * 10000 + (c.get(Calendar.MONTH) + 1) * 100 + c.get(Calendar.DAY_OF_MONTH);
        return d;
    }

    public static int getDay(long second) {
        return getDay(new Date(second * 1000));
        // Calendar c = Calendar.getInstance();
        // c.setTimeInMillis(second * 1000);
        // int d = c.get(Calendar.YEAR) * 10000 + (c.get(Calendar.MONTH) + 1) *
        // 100 + c.get(Calendar.DAY_OF_MONTH);
        // return d;
    }

    public static Date getDate(long second) {
        return new Date(second * 1000);
    }

    public static int getMonthAndDay(Date date) {
        Calendar c = Calendar.getInstance();
        c.setTime(date);
        int monthAndDay = (c.get(Calendar.MONTH) + 1) * 10000 + (c.get(Calendar.DAY_OF_MONTH)) * 100;
        return monthAndDay;
    }

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

    public static boolean isBossBegin() {
        Calendar calendar = Calendar.getInstance();
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        if (hour == 20 && minute == 50) {
            return true;
        }
        return false;
    }

    public static boolean isBossFightBegin() {
        Calendar calendar = Calendar.getInstance();
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        if (hour == 21 && minute == 0) {
            return true;
        }
        return false;
    }

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
     * 要塞战结束时间 Method: isFortressBattleBeginEnd @Description: TODO @return @return boolean @throws
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
     *
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
     * 判断时间是否本周 Method: isThisWeek @Description: TODO @param dayTime @return @return boolean @throws
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
     * 获取本周一 Method: getThisWeekMonday @Description: TODO @return @return int @throws
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
     * 获取本周日 Method: getThisWeekSunday @Description: TODO @return @return int @throws
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

    public static void main(String[] args) {
        // System.out.println(isThisWeekSaturday1930ToSunday2015());
        // System.out.println(DateHelper.dayiy(DateHelper.parseDate("2016-8-26
        // 11:00:00"),new Date()));
        System.out.println(getNowHourAndMins());
        System.out.println(getCurrentDay());
    }

    /**
     * 获取跨服战第几天
     *
     * @return
     */
    public static int getDayOfCrossWar() {
        return DateHelper.dayiy(GameContext.CROSS_BEGIN_DATA, new Date());
    }

    /**
     * 获取当前小时和分钟
     *
     * @return
     */
    public static String getNowHourAndMins() {
        return DateHelper.dateFormat4.format(new Date());
    }

    /**
     * 跨服战设置阵型时间
     *
     * @return
     */
    public static boolean isSetCrossFromTime() {
        int day = getDayOfCrossWar();
        if (day == 3) {
            return isInTime(0, 0, 0, 12, 0, 0) || isInTime(13, 0, 0, 16, 0, 0) || isInTime(17, 0, 0, 20, 0, 0) || isInTime(21, 0, 0, 23, 59, 59);
        } else if (day == 4) {
            return isInTime(0, 0, 0, 12, 0, 0) || isInTime(12, 30, 0, 15, 30, 0) || isInTime(16, 0, 0, 19, 0, 0) || isInTime(19, 30, 0, 22, 30, 0) || isInTime(23, 0, 0, 23, 59, 59);
        } else if (day == 5) {
            return isInTime(0, 0, 0, 12, 0, 0) || isInTime(12, 15, 0, 20, 0, 0);
        }
        return false;
    }

    /**
     * 跨服军团战报名时间
     *
     * @return
     */
    public static boolean isInCrossPartyRegTime() {
        int day = getDayOfCrossWar();
        if (day == 1) {
            return isInTime(21, 00, 0, 23, 59, 59);
        } else if (day == 2) {
            return isInTime(0, 0, 0, 23, 59, 59);
        }
        return false;
    }

    /**
     * 跨服军团战参赛资格争夺
     *
     * @return
     */
    public static boolean isInCPFightForQualificate() {
        int day = getDayOfCrossWar();
        if (day == 1) {
            return isInTime(0, 0, 0, 21, 00, 0);
        }
        return false;
    }

    /**
     * 跨服军团战布阵时间
     *
     * @return
     */
    public static boolean isInCrossPartySetFormTime() {
        int dayNum = getDayOfCrossWar();
        return isInCPGroupSetFormTime(dayNum) || isInCPFinalSetFormTime(dayNum);
    }

    /**
     * 跨服军团战小组赛布阵时间
     *
     * @return
     */
    public static boolean isInCPGroupSetFormTime(int dayNum) {
        if (dayNum == 3) {
            return isInTime(0, 0, 0, 17, 0, 0);
        }
        return false;
    }

    /**
     * 跨服军团小组战
     *
     * @param dayNum
     * @return
     */
    public static boolean isinCPGruopFight(int dayNum, int group) {
        if (dayNum == 3) {
            if (group == CrossPartyConst.group_A) {
                return isInTime(17, 0, 0, 18, 0, 0);
            } else if (group == CrossPartyConst.group_B) {
                return isInTime(18, 0, 0, 19, 0, 0);
            }
            if (group == CrossPartyConst.group_C) {
                return isInTime(19, 0, 0, 20, 0, 0);
            }
            if (group == CrossPartyConst.group_D) {
                return isInTime(20, 0, 0, 21, 0, 0);
            }
        }
        return false;
    }

    /**
     * 跨服军团決賽
     *
     * @param dayNum
     * @return
     */
    public static boolean isinCPFinalFight(int dayNum) {
        if (dayNum == 4) {
            return isInTime(14, 0, 0, 16, 0, 0);
        }
        return false;
    }

    /**
     * 跨服军团领奖
     *
     * @param dayNum
     * @return
     */
    public static boolean isinCpReceiveReward(int dayNum) {
        if (dayNum == 4) {
            return isInTime(16, 0, 0, 23, 59, 59);
        } else if (dayNum == 5) {
            return isInTime(0, 0, 0, 23, 59, 59);
        }
        return false;
    }

    /**
     * 跨服军团战决赛布阵时间
     *
     * @return
     */
    public static boolean isInCPFinalSetFormTime(int dayNum) {
        if (dayNum == 3) {
            return isInTime(21, 0, 0, 23, 59, 59);
        } else if (dayNum == 4) {
            return isInTime(0, 0, 0, 14, 0, 0);
        }
        return false;
    }

    public static boolean isInTime(int hours1, int mins1, int sce1, int hours2, int mins2, int sce2) {
        Calendar c = Calendar.getInstance();
        c.set(Calendar.HOUR_OF_DAY, hours1);
        c.set(Calendar.MINUTE, mins1);
        c.set(Calendar.SECOND, sce1);
        int s1 = (int) (c.getTime().getTime() / SECOND_MS);
        c.set(Calendar.HOUR_OF_DAY, hours2);
        c.set(Calendar.MINUTE, mins2);
        c.set(Calendar.SECOND, sce2);
        int s2 = (int) (c.getTime().getTime() / SECOND_MS);
        int cc = getCurrentSecond();
        return s1 <= cc && cc <= s2;
    }

    /**
     * 跨服战16-8
     *
     * @return
     */
    public static boolean isKnockBegin_16_8() {
        int day = getDayOfCrossWar();
        String nowTime = getNowHourAndMins();
        return (day == 4 && (nowTime.compareTo("12:00:00") > 0) && ("12:30:00".compareTo(nowTime) > 0));
    }

    /**
     * 跨服战8-4
     *
     * @return
     */
    public static boolean isKnockBegin_8_4() {
        int day = getDayOfCrossWar();
        String nowTime = getNowHourAndMins();
        return (day == 4 && (nowTime.compareTo("15:30:00") > 0) && ("16:00:00".compareTo(nowTime) > 0));
    }

    /**
     * 跨服战4-2
     *
     * @return
     */
    public static boolean isKnockBegin_4_2() {
        int day = getDayOfCrossWar();
        String nowTime = getNowHourAndMins();
        return (day == 4 && (nowTime.compareTo("19:00:00") > 0) && ("19:30:00".compareTo(nowTime) > 0));
    }

    /**
     * 跨服战2-1
     *
     * @return
     */
    public static boolean isKnockBegin2_1() {
        int day = getDayOfCrossWar();
        String nowTime = getNowHourAndMins();
        return (day == 4 && (nowTime.compareTo("22:30:00") > 0) && ("23:00:00".compareTo(nowTime) > 0));
    }

    /**
     * 总决赛(半决赛)
     *
     * @return
     */
    public static boolean isFinalBeginHalf() {
        int day = getDayOfCrossWar();
        String nowTime = getNowHourAndMins();
        return (day == 5 && (nowTime.compareTo("12:00:00") > 0) && ("12:15:00".compareTo(nowTime) > 0));
    }

    /**
     * 总决赛(决赛)
     *
     * @return
     */
    public static boolean isFinalBeginFinal() {
        int day = getDayOfCrossWar();
        String nowTime = getNowHourAndMins();
        return (day == 5 && (nowTime.compareTo("20:00:00") > 0) && ("20:15:00".compareTo(nowTime) > 0));
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
}