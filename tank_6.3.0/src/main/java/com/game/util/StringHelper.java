package com.game.util;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author zc
 * @ClassName:StringHelper
 * @Description:字符串相关工具
 * @date 2017年10月21日
 */
public class StringHelper {

    public static Set<Integer> string2IntSet(String str) {
        Set<Integer> set = new HashSet<>();
        if (str != null && str.length() > 0) {
            String[] strArr = str.split(",");
            for (String s : strArr) {
                set.add(Integer.parseInt(s));
            }
        }
        return set;
    }

    public static String collectionInt2String(Collection<Integer> collection) {
        if (collection == null || collection.isEmpty()) {
            return "";
        } else {
            StringBuilder sb = new StringBuilder();
            for (Integer val : collection) {
                sb.append(val).append(",");
            }
            return sb.deleteCharAt(sb.length() - 1).toString();
        }
    }

    /**
     * 以正则表达式提取字符串
     *
     * @param regex
     * @param source
     * @return
     */
    public static String getMatcher(String regex, String source) {
        String result = "";
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(source);
        if (matcher.find()) {
            result = matcher.group(1);
        }
        return result;
    }

    /**
     * 根据将领名类似“[觉]鲷哥+5”格式返回“鲷哥”
     *
     * @param name
     * @return
     */
    public static String getAwakenHeroName(String name) {
        //正则规则:去掉[觉];剩下不包含"+数字"则为将领名
        String regex = "(?:\\[.*\\])(.*[^\\+\\d])";

        return getMatcher(regex, name);
    }

    public static void main(String[] args) {
        LogUtil.info(getAwakenHeroName("[觉]鲷哥+5"));
        LogUtil.info(getAwakenHeroName("[觉]鲷哥"));
    }
}
