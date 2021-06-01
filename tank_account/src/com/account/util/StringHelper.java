package com.account.util;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author TanDonghai
 * @ClassName StringHelper.java
 * @Description TODO
 * @date 创建时间：2016年7月25日 下午5:03:31
 */
public class StringHelper {
    /**
     * 去除字符串中的空格、回车、换行符、制表符
     *
     * @param str
     * @return
     */
    public static String replaceBlank(String str) {
        if (CheckNull.isNullTrim(str)) {
            return "";
        }

        Pattern p = Pattern.compile("\\s*|\t|\r|\n");
        Matcher m = p.matcher(str);
        return m.replaceAll("");
    }

    public static List<Long> parserString2ListLong(String str) {
        List<Long> longList = new ArrayList<>();
        if (str != null && !"".equals(str)) {
            String[] arr = str.split(",");
            for (String s : arr) {
                longList.add(Long.parseLong(s));
            }
        }
        return longList;
    }
}
