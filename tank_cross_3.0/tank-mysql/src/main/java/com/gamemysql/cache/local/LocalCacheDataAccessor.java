package com.gamemysql.cache.local;

import com.gamemysql.core.entity.DataAccessor;
import com.gamemysql.core.entity.DataEntity;
import com.gamemysql.core.entity.DataEntityOperator;

import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 12:01 @Description :java类作用描述
 */
public class LocalCacheDataAccessor<K, R, V extends DataEntity<K, R>>
    implements DataAccessor<K, R, V> {
  private final DataEntityOperator<K, R, V> operator; // 实体类型

  public LocalCacheDataAccessor(DataEntityOperator<K, R, V> operator) {
    this.operator = operator;
  }

  @Override
  public K insert(V record) {
    return null;
  }

  @Override
  public V getByPrimary(K id) {
    return null;
  }

  @Override
  public V get(R ref, K id) {
    return null;
  }

  @Override
  public Map<K, V> getByPrimarys(Set<K> ids) {
    return null;
  }

  @Override
  public List<V> getByForeign(R ref) {
    return null;
  }

  @Override
  public Map<K, V> getMapByForeign(R ref) {
    return null;
  }

  @Override
  public boolean update(V record) {
    return false;
  }

  @Override
  public boolean delete(V id) {
    return false;
  }

  @Override
  public DataEntityOperator<K, R, V> getEntityOperator() {
    return operator;
  }
}
