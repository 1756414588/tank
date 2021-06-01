package com.gamemysql.jdbc;

import com.gamemysql.core.entity.DataAccessor;
import com.gamemysql.core.entity.DataEntity;

import java.util.List;
import java.util.Map;

public interface JdbcDataAccessor<K, R, V extends DataEntity<K, R>>
    extends RowMapper<V>, DataAccessor<K, R, V> {
  V getByUnique(final Map<String, ?> index);

  List<V> getsByFulltext(final Map<String, ?> index);

  List<V> getAll();

  Map<K, V> getMapAll();

  <T> T query(String sql, RowMapper<T> mapper, List params);

  <T> List<T> queryList(String sql, RowMapper<T> mapper, List params);

  <T> List<T> queryList(String sql, List params);

  List<V> queryListByWhere(String where, List params);

  List<Map<String, Object>> queryMapList(String sql, List params);

  int delete(Map<String, Object> parameters);

  long countByFulltext(Map<String, Object> index);

  List<V> pageByFulltext(Map<String, Object> index, int pageSize, int startNum);

  List<V> pageRank(Map<String, Object> index, String desc, String asc, int pageSize, int startNum);

  /**
   * 以entity为标准检查数据库表是不是与entity对应
   *
   * <p>1、自动创建表 2、自动修补表中缺少的字段 3、表中字段多于实体属性时，不进行删除操作，需要手动介入 (安全) 4、自动补充索引，删除索引
   */
  public void checkDatabaseTableWithEntity();
}
