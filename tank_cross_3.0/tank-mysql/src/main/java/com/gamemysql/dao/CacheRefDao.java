package com.gamemysql.dao;

import com.gamemysql.cache.DataCacheManager;
import com.gamemysql.cache.Foreign;
import com.gamemysql.core.entity.RefDataEntity;
import com.gamemysql.dao.query.QueryFilter;
import com.gamemysql.jdbc.JdbcDataAccessor;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public abstract class CacheRefDao<K, R, V extends RefDataEntity<K, R>> extends CacheDao<K, R, V> {
  protected CacheRefDao(DataCacheManager manager, Class<V> entityClass) {
    super(manager, entityClass);
  }

  @Override
  public void initCacheData() {
    final JdbcDataAccessor mapper = manager.getMapper(entityClass);
    final Map<K, V> mapAll = mapper.getMapAll();
    Map<Foreign, Map<K, V>> datas = new ConcurrentHashMap<>(mapAll.size());
    for (Map.Entry<K, V> entry : mapAll.entrySet()) {
      K primary = (K) mapper.getEntityOperator().getPrimary(entry.getValue());
      R foreign = (R) mapper.getEntityOperator().getForeign(entry.getValue());
      final Foreign key = new Foreign(entityClass, foreign);
      Map<K, V> result = datas.get(key);
      if (result == null) {
        result = new ConcurrentHashMap<>();
        datas.put(key, result);
      }
      result.put(primary, entry.getValue());
    }
    manager.getCache(entityClass).putAll(datas);
  }

  @Override
  public V get(R ref, K id) {
    return manager.get(entityClass, ref, id);
  }

  public List<V> findAll(R ref) {
    return manager.getList(entityClass, ref);
  }

  protected V get(R ref, QueryFilter<K, R, V> filter) {
    return manager.get(entityClass, ref, filter);
  }

  public List<V> findAll(R ref, QueryFilter<K, R, V> filter) {
    return manager.getList(entityClass, ref, filter);
  }

  public Map<K, V> getMap(R ref) {
    return manager.gets(entityClass, ref);
  }

  protected Map<K, V> getMap(R ref, QueryFilter<K, R, V> filter) {
    return manager.gets(entityClass, ref, filter);
  }
}
