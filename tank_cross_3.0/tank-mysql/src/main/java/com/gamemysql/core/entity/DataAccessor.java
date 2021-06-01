package com.gamemysql.core.entity;

import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 15:16 @Description :数据访问器
 */
public interface DataAccessor<K, R, V extends DataEntity<K, R>> {
  K insert(final V record);

  V getByPrimary(final K id);

  V get(final R ref, final K id);

  Map<K, V> getByPrimarys(final Set<K> ids);

  List<V> getByForeign(final R ref);

  Map<K, V> getMapByForeign(final R ref);

  boolean update(final V record);

  boolean delete(final V record);

  DataEntityOperator<K, R, V> getEntityOperator();
}
