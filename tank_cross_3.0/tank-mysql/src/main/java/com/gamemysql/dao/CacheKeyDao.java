package com.gamemysql.dao;

import com.gamemysql.cache.DataCacheManager;
import com.gamemysql.cache.Foreign;
import com.gamemysql.core.entity.KeyDataEntity;
import com.gamemysql.dao.query.QueryFilter;
import com.gamemysql.jdbc.JdbcDataAccessor;
import org.apache.commons.collections.CollectionUtils;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public abstract class CacheKeyDao<K, V extends KeyDataEntity<K>> extends CacheDao<K, K, V> {
  protected CacheKeyDao(DataCacheManager manager, Class<V> entityClass) {
    super(manager, entityClass);
  }

  @Override
  public void initCacheData() {
    final JdbcDataAccessor mapper = manager.getMapper(entityClass);
    final Map<K, V> mapAll = mapper.getMapAll();
    for (Map.Entry<K, V> entry : mapAll.entrySet()) {
      K primary = (K) mapper.getEntityOperator().getPrimary(entry.getValue());
      Map<K, V> result = new ConcurrentHashMap<>(1, 1);
      result.put(primary, entry.getValue());
      manager.getCache(entityClass).put(new Foreign(entityClass, primary), result);
    }
  }

  @Override
  public V get(K id) {
    return manager.get(entityClass, id, id);
  }

  public V findOne(QueryFilter<K, K, V> filter) {
    Collection<V> values = manager.gets(entityClass, filter).values();
    if (values.size() == 1) {
      return (V) CollectionUtils.get(values, 0);
    }
    return null;
  }

  @Override
  public List<V> findAll() {
    return manager.getList(entityClass);
  }

  @Override
  public List<V> findAll(QueryFilter<K, K, V> filter) {
    return new ArrayList<V>(manager.gets(entityClass, filter).values());
  }

  public Map<K, V> getMap() {
    return manager.gets(entityClass);
  }

  public Map<K, V> getMap(QueryFilter<K, K, V> filter) {
    return manager.gets(entityClass, filter);
  }

  @Override
  public long count() {
    return manager.gets(entityClass).size();
  }

  @Override
  public long count(QueryFilter<K, K, V> filter) {
    return manager.gets(entityClass, filter).size();
  }
}
