package com.gamemysql.dao.query;

import com.gamemysql.core.entity.DataEntity;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 15:33 @Description :过滤器
 */
public abstract class QueryFilter<K, R, V extends DataEntity<K, R>> implements IQueryFilter<V> {
  /** 是否停止查询,用于控制查询数量所需 */
  @Override
  public boolean stopped() {
    return false;
  }

  /**
   * 验证指定实体是否满足条件
   *
   * @param value 实体
   */
}
