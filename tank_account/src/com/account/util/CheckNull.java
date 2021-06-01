package com.account.util;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;

/**
 * @author TanDonghai
 * @ClassName CheckNull.java
 * @Description 空判断
 * @date 创建时间：2016年7月14日 下午2:11:24
 */
public class CheckNull {
    /**
     * 检查字符串是否为null或空字符串
     *
     * @param str
     * @return 当字符串为null或为空字符串，或trim()后为空字符串，返回true
     */
    public static boolean isNullTrim(String str) {
        return null == str || "".equals(str.trim());
    }

    /**
     * 检查对象是否为null
     *
     * @param obj
     * @return 对象为null，返回true
     */
    public static boolean isNull(Object obj) {
        return null == obj;
    }

    /**
     * 检查集合对象是否为null或者长度为空
     *
     * @param col
     * @return
     */
    public static boolean isEmpty(Collection<?> col) {
        return null == col || col.isEmpty();
    }

    /**
     * 检查Map是否为null或为空
     *
     * @param map
     * @return
     */
    public static boolean isEmpty(Map<?, ?> map) {
        return null == map || map.isEmpty();
    }

    /**
     * 检查数组是否为null或长度为0
     *
     * @param arr
     * @return
     */
    public static boolean isEmpty(Object... arr) {
        return null == arr || arr.length == 0;
    }

    public static void main(String[] args) {
		/*LOG.error(isEmpty());
		LOG.error(isEmpty(1));
		LOG.error(isEmpty(""));
		LOG.error(isNull(null));
		LOG.error(isNullTrim(""));
		LOG.error(isNullTrim("  "));
		LOG.error(isEmpty(new HashMap<>(10)));
		LOG.error(isEmpty(new HashSet<>(10)));
		LOG.error(isEmpty(new ArrayList<>()));*/
    }
}
