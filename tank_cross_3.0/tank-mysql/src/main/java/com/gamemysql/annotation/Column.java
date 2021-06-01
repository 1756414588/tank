package com.gamemysql.annotation;

import java.lang.annotation.*;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 12:00 @Description :映射表字段
 */
@Documented
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
public @interface Column {
  /** @return 字段名 */
  String value();

  /** @return 备注 */
  String comment() default "";

  /**
   * 索引
   *
   * @return
   */
  boolean unique() default false;

  /**
   * 是否允许为null
   *
   * @return
   */
  boolean nullable() default true;

  /**
   * 是不是普通索引
   *
   * @return
   */
  boolean index() default false;

  /**
   * 字段长度 varchar类型，必须注明，否则生成的表结构会是默认长度
   *
   * <p>当设置的长度>=65535时，字段类型自动升为text
   *
   * <p>当设置长度为{@link Integer#MAX_VALUE} 时，类型升为longtext
   *
   * @return
   */
  int length() default 255;

  /**
   * 表示该值一共显示15位整数
   *
   * @return
   */
  int precision() default 15;

  /**
   * 小数点后面5位
   *
   * @return
   */
  int scale() default 5;

  /**
   * 默认值
   *
   * @return
   */
  String defaultValue() default "";
}
