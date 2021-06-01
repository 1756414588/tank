package com.hundredcent.game.aop.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 保存优化基础注解，所有需要执行注入操作的JavaBean类都需要添加该注解
 *
 * @author Tandonghai
 * @date 2018-01-09 9:43
 */
@Target({ ElementType.TYPE, ElementType.METHOD, ElementType.FIELD })
@Retention(RetentionPolicy.RUNTIME)
public @interface SaveOptimize {

    String name() default "";

    SaveLevel level() default SaveLevel.CYCLE;
}
