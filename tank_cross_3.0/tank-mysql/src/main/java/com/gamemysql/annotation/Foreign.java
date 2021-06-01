package com.gamemysql.annotation;

import java.lang.annotation.*;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 12:00 @Description :外键标识
 */
@Documented
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
public @interface Foreign {}
