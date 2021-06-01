package com.gamemysql.dao;

import com.gamemysql.core.entity.DataEntity;
import com.gamemysql.dao.query.QueryFilter;

import java.util.List;

public interface Repostiory<K, R, V extends DataEntity<K, R>> {

  V get(K k);

  V get(R r, K k);

  void insert(V value);

  void update(V value);

  void delete(V value);

  List<V> findAll();

  List<V> findAll(QueryFilter<K, R, V> filter);

  long count();

  long count(QueryFilter<K, R, V> filter);
}
