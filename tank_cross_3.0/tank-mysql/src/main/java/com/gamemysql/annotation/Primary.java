package com.gamemysql.annotation;

import java.lang.annotation.*;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 12:00 @Description :主键标识
 */
@Documented
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
public @interface Primary {

  GenerationType strategy() default GenerationType.GEN;

  public static enum GenerationType {
    // AUTO是否自增id
    AUTO,
    GEN;

    private GenerationType() {}
  }
}
