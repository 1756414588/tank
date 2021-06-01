package com.game.util;

import java.lang.reflect.Field;

/**
 * @author Tandonghai
 * @date 2018-01-23 15:56
 */
public class ReflectUtil {
    private ReflectUtil() {
    }

    public static boolean setDeclaredField(Class<?> clazz, Object obj, String fieldName, Object value) {
        if (null == clazz || null == fieldName) {
            return false;
        }

        try {
            Field field = clazz.getDeclaredField(fieldName);
            field.setAccessible(true);
            field.set(obj, value);
            return true;
        } catch (Exception ex) {
            LogUtil.error("通过反射设置参数出错, clazz:" + clazz.getName() + ", fieldName:" + fieldName, ex);
            return false;
        }
    }
}
