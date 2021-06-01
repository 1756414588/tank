package com.game.util;

import org.apache.commons.lang3.time.DateUtils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class DateHelper {
  public static final String format1 = "yyyy-MM-dd HH:mm:ss";
  public static final String format2 = "yyyy-MM-dd";
  public static final String format3 = "yyyy-MM-dd HH:mm:ss.SSS";
  public static final String format4 = "HH:mm:ss";
  public static SimpleDateFormat dateFormat1 = new SimpleDateFormat(format1);
  public static SimpleDateFormat dateFormat2 = new SimpleDateFormat(format2);
  public static SimpleDateFormat dateFormat3 = new SimpleDateFormat(format3);
  public static SimpleDateFormat dateFormat4 = new SimpleDateFormat(format4);

  public static boolean isSameDate(Date date1, Date date2) {
    if (date1 == null || date2 == null) {
      return false;
    }
    return DateUtils.isSameDay(date1, date2);
  }

  public static boolean isSameDate(Calendar cal1, Calendar cal2) {
    return DateUtils.isSameDay(cal1, cal2);
  }

  public static boolean isBeforeOneDay(Calendar cal1) {
    Calendar calendar = Calendar.getInstance();
    calendar.add(Calendar.DATE, -1);
    return DateUtils.isSameDay(cal1, calendar);
  }

  public static boolean isToday(Date date) {
    return DateUtils.isSameDay(date, new Date());
  }

  public static String displayDateTime() {
    return dateFormat3.format(new Date());
  }

  public static int getNowMonth() {
    Calendar calendar = Calendar.getInstance();
    return calendar.get(Calendar.MONTH + 1);
  }

  public static String displayNowDateTime() {
    return dateFormat1.format(new Date());
  }

  public static String formatDateTime(Date date, String format) {
    SimpleDateFormat simpleDateFormat = new SimpleDateFormat(format);
    return simpleDateFormat.format(date);
  }

  public static String formatDateMiniTime(Date date) {
    return dateFormat3.format(date);
  }

  public static Date getInitDate() {
    Calendar calendar = Calendar.getInstance();
    calendar.set(2008, 1, 1);
    return calendar.getTime();
  }

  public static long getServerTime() {
    return Calendar.getInstance().getTime().getTime() / 1000;
  }

  public static long dvalue(Calendar calendar, Date date) {
    if (date == null || calendar == null) {
      return 0;
    }
    long dvalue = (calendar.getTimeInMillis() - date.getTime()) / 1000;
    return dvalue;
  }

  // cdTime --秒数
  public static boolean isOutCdTime(Date date, long cdTime) {
    Date nowDate = new Date();
    return (nowDate.getTime() - date.getTime()) > cdTime * 1000;
  }

  public static Date parseDate(String dateString) {
    try {
      return dateFormat1.parse(dateString);
    } catch (ParseException e) {
      e.printStackTrace();
    }
    return null;
  }

  public static boolean isInTime(Date now, Date begin, Date end) {
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
  public static int dayiy(Date origin, Date now) {
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

  public static void main(String[] args) {
    // System.out.println(dayiy(new Date(),new Date()));

    System.out.println(formatDateTime(new Date(), format2));

    Calendar orignC = Calendar.getInstance();
    orignC.setTime(new Date());
    orignC.add(Calendar.DATE, 6);

    System.out.println(formatDateTime(orignC.getTime(), format2));
  }

  public static Date someDayAfter(Date origin, int day) {
    Calendar orignC = Calendar.getInstance();
    orignC.setTime(origin);
    orignC.add(Calendar.DATE, day);
    return orignC.getTime();
  }
}
