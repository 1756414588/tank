/** */
package com.gamemysql.dao.query;

import com.gamemysql.core.entity.DataEntity;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 15:33 @Description :查询过滤器
 */
public interface IQueryFilter<T extends DataEntity> {

  /**
   * 验证指定实体是否满足条件
   *
   * @param entity 实体
   */
  public boolean check(T entity);

  /**
   * 是否停止查询,用于控制查询数量所需
   *
   * @param
   */
  public boolean stopped();
}
