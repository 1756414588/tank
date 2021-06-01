package com.gamemysql.tabecheck;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 15:39 @Description :java类作用描述 * 检查实体和表的映射关系的工具 *
 *     <p>* 自动补全SQL 发生在三种情况下：1、少字段了 2、少表了 3、修改字段长度(长度自动变长，不会自动缩短)
 */
public interface EntityTableChecker {

  public boolean check();
}
