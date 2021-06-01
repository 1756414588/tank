package com.gamemysql.annotation;

import java.lang.annotation.*;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 12:01 @Description :表名注解
 */
@Documented
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface Table {
  /** @return 表名 */
  String value();

  /** @return 备注 */
  String comment() default "";

  TableEngine engine() default TableEngine.InnoDB;

  /**
   * 返回当前实体类的抓取策略.
   *
   * @return 返回配置的抓取策略，默认值为什么用，什么时候初始化.
   */
  FeatchType fetch() default FeatchType.USE;

  public enum TableEngine {
    InnoDB,
    MyISAM;

    private TableEngine() {}
  }

  /**
   * 抓取策略.
   *
   * <p>1.启动服务器的时候，初始化当前实体数据.<br>
   * 2.什么时候用，什么时候初始化当前实体数据.<br>
   */
  public enum FeatchType {
    /** 启动服务器的时候，初始化当前实体数据. */
    START,
    /** 什么时候用，什么时候初始化当前实体数据. */
    USE;
  }
}
