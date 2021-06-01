package com.gamemysql.annotation;

import java.lang.annotation.*;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 12:00 @Description :标识该字段为实体中特有属性，不对应数据库中字段
 */
@Documented
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
public @interface EntityField {
  String value() default "";
}
