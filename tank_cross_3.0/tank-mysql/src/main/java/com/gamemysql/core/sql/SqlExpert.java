/** */
package com.gamemysql.core.sql;

import com.gamemysql.annotation.Table;

import java.lang.reflect.Field;
import java.util.List;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 15:32 @Description :数据库建表sql相关
 */
public interface SqlExpert {

  /**
   * 生成创建数据库表的sql
   *
   * @param table
   * @param columnFileds
   * @return
   */
  public String genCreateTableSql(Table table, List<Field> columnFileds);

  /**
   * 自动添加表字段
   *
   * @param table
   * @param field
   * @return
   */
  public String genAddTableColumnSql(Table table, Field field);

  /**
   * 获取注解的表字段名称，如果没有 value 使用自定名称
   *
   * @param field
   * @return
   */
  public String getColumnName(Field field);

  /**
   * 修改表类型
   *
   * @param table
   * @param field
   * @return
   */
  String genModifyTableColumnSql(Table table, Field field);

  public String genCreateIndexSql(String tableName, String columnName);

  public String genDropIndexSql(String tableName, String columnName);

  public String genDropUnIndexSql(String tableName, String columnName);

  public String genCreateUnIndexSql(String tableName, String columnName);

  public String genAddUpdateTimeColumnSql(Table table);

  public String genCreateDatabaseSql(String databaseName);
}
