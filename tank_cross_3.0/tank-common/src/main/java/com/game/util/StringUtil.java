package com.game.util;

import java.util.Arrays;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/26 11:32
 * @description：
 */
public class StringUtil {

    public static String strFormat(String str) {
        if (str == null) {
            str = "";
        }
        return new String(Arrays.copyOf(str.toCharArray(), 20)).replaceAll("" + (char) 0, " ");
    }
}
