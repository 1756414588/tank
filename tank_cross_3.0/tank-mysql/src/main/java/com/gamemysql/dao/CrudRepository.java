package com.gamemysql.dao;

import com.gamemysql.core.entity.DataEntity;
import com.gamemysql.core.entity.DataEntityOperator;
import com.gamemysql.dao.query.QueryFilter;
import com.gamemysql.jdbc.SqlJdbcDataAccessor;

import javax.sql.DataSource;
import java.util.List;

public class CrudRepository<K, R, V extends DataEntity<K, R>> implements Repostiory<K, R, V> {
  public final SqlJdbcDataAccessor<K, R, V> accessor;

  protected CrudRepository(DataSource dataSource, Class<V> entityClass) {
    DataEntityOperator<K, R, V> operator = new DataEntityOperator<>(entityClass);
    this.accessor = new SqlJdbcDataAccessor<>(operator, dataSource);
    this.accessor.checkDatabaseTableWithEntity();
  }

  @Override
  public V get(K k) {
    return accessor.getByPrimary(k);
  }

  @Override
  public V get(R r, K k) {
    return accessor.get(r, k);
  }

  @Override
  public void insert(V value) {
    accessor.insert(value);
  }

  @Override
  public void update(V value) {
    accessor.update(value);
  }

  @Override
  public void delete(V value) {
    accessor.delete(value);
  }

  @Override
  public List<V> findAll() {
    return accessor.getAll();
  }

  @Override
  public List<V> findAll(QueryFilter filter) {
    throw new UnsupportedOperationException("直接使用sql查询吧");
  }

  public List<V> findAll(R ref) {
    return accessor.getByForeign(ref);
  }

  @Override
  public long count() {
    return accessor.countByFulltext(null);
  }

  @Override
  public long count(QueryFilter filter) {
    throw new UnsupportedOperationException("直接使用sql查询吧");
  }
}
