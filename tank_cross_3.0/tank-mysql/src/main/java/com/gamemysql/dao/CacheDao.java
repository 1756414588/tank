package com.gamemysql.dao;

import com.gamemysql.annotation.Table;
import com.gamemysql.cache.DataCacheManager;
import com.gamemysql.core.entity.DataEntity;
import com.gamemysql.dao.query.QueryFilter;
import com.gamemysql.jdbc.JdbcDataAccessor;

import java.util.List;

public abstract class CacheDao<K, R, V extends DataEntity<K, R>> implements Repostiory<K, R, V> {
  protected final DataCacheManager manager;
  protected final Class<V> entityClass;
  protected boolean isPermanent;

  protected CacheDao(DataCacheManager manager, Class<V> entityClass) {
    this.manager = manager;
    this.entityClass = entityClass;
    manager.init(entityClass);
    _initCacheData();
  }

  protected void _initCacheData() {
    final JdbcDataAccessor mapper = manager.getMapper(entityClass);
    if (mapper.getEntityOperator().featchType == Table.FeatchType.START) {
      initCacheData();
    }
  }

  public abstract void initCacheData();

  @Override
  public V get(K k) {
    throw new UnsupportedOperationException();
  }

  @Override
  public V get(R ref, K id) {
    throw new UnsupportedOperationException();
  }

  /**
   * 是否永久驻留在内存中
   *
   * @return
   */
  protected boolean isPermanent() {
    return false;
  }

  @Override
  public void insert(V value) {
    manager.insert(value);
  }

  @Override
  public void update(V value) {
    manager.update(value);
  }

  @Override
  public void delete(V value) {
    manager.delete(value);
  }

  @Override
  public List<V> findAll(QueryFilter<K, R, V> filter) {
    throw new UnsupportedOperationException();
  }

  @Override
  public List<V> findAll() {
    throw new UnsupportedOperationException();
  }

  @Override
  public long count() {
    throw new UnsupportedOperationException();
  }

  @Override
  public long count(QueryFilter<K, R, V> filter) {
    throw new UnsupportedOperationException();
  }
}
