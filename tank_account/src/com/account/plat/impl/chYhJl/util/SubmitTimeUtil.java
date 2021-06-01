package com.account.plat.impl.chYhJl.util;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;

public class SubmitTimeUtil {
    public static final String DEFAULT_FORMAT = "yyyyMMddHHmmss";

    public static Timestamp toTimestamp(String submitTime) {
        submitTime = new StringBuilder().append(
                submitTime.substring(0, 4) + "-" + submitTime.substring(4, 6) + "-" + submitTime.substring(6, 8) + " " + submitTime.substring(8, 10) + ":"
                        + submitTime.substring(10, 12) + ":" + submitTime.substring(12, 14)).toString();
        return Timestamp.valueOf(submitTime);
    }

    public static String toString(Date date) {
        return toString(date, DEFAULT_FORMAT);
    }

    public static String toString(Date date, String format) {
        SimpleDateFormat dateFormat = new SimpleDateFormat(format);
        if (date == null) {
            return "";
        }
        return dateFormat.format(date);
    }
}
