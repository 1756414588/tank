package com.gamemysql.jdbc;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.alibaba.fastjson.JSONPObject;
import com.gamemysql.core.entity.DataEntity;
import com.gamemysql.core.entity.DataEntityOperator;
import com.gamemysql.core.sql.MysqlSqlExpert;
import com.gamemysql.core.sql.SqlExpert;
import com.gamemysql.tabecheck.EntityTableChecker;
import com.gamemysql.tabecheck.MysqlEntityTableChecker;
import com.google.common.collect.Lists;
import org.apache.log4j.Logger;

import javax.sql.DataSource;
import java.lang.reflect.Field;
import java.sql.*;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 每个表一个 存取器
 *
 * @param <K>
 * @param <R>
 * @param <V>
 */
public class SqlJdbcDataAccessor<K, R, V extends DataEntity<K, R>>
    implements JdbcDataAccessor<K, R, V> {

  public static Logger logger = Logger.getLogger("ERROR");

  private final DataEntityOperator<K, R, V> operator; // 实体类型
  private final DataSource dataSource; // 数据源
  private final SqlBuilder<K, R, V> sqlBuilder;
  private final SqlExpert sqlExpert;
  private final EntityTableChecker entityTableChecker;

  public SqlJdbcDataAccessor(DataEntityOperator<K, R, V> operator, DataSource dataSource) {
    this.operator = operator;
    this.dataSource = dataSource;
    this.sqlBuilder = new SqlBuilder<>(operator);
    this.sqlExpert = new MysqlSqlExpert();
    entityTableChecker = new MysqlEntityTableChecker(dataSource, operator.entityClass, sqlExpert);
  }

  @Override
  public K insert(V record) {
    Connection conn = null;
    PreparedStatement statement = null;
    try {
      boolean withKey = operator.fields.get(operator.primary).get(record) != null;
      conn = dataSource.getConnection();
      String sql = withKey ? sqlBuilder.insertWithKey : sqlBuilder.insertWithGeneratedKey;
      statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
      int index = 1;
      for (int i = 0; i < operator.fields.size(); i++) {
        if (withKey || i != operator.primary) {

          Field field = operator.fields.get(i);
          Object o = null;
          if (field.getType().equals(JSONObject.class) || field.getType().equals(JSONArray.class)) {
            o = field.get(record).toString();
          } else {
            o = field.get(record);
          }

          statement.setObject(index++, o);
        }
      }
      int result = statement.executeUpdate();
      if (result == 1) {
        ResultSet generatedKeys = statement.getGeneratedKeys();
        if (generatedKeys == null || !generatedKeys.next()) {
          return operator.getPrimary(record);
        } else {
          Object id = convertValueToRequiredType(generatedKeys.getObject(1), operator.primaryClass);
          operator.fields.get(operator.primary).set(record, id);
          return (K) id;
        }
      }
    } catch (Exception e) {
      K primary = operator.getPrimary(record);
      R foreign = operator.getForeign(record);
      logger.error(
          String.format(
              "execute error %s %s %s", record.getClass().getSimpleName(), foreign, primary),
          e);
    } finally {
      close(conn, statement);
    }
    return null;
  }

  @Override
  public V getByPrimary(K id) {
    Connection conn = null;
    PreparedStatement statement = null;
    try {
      conn = dataSource.getConnection();
      statement = conn.prepareStatement(sqlBuilder.selectByPrimary);
      statement.setObject(1, id);
      int rowNum = 0;
      ResultSet rs = statement.executeQuery();
      if (rs.next()) {
        return mapRow(rs, rowNum++);
      }
    } catch (Exception e) {
      logger.error("execute error", e);
    } finally {
      close(conn, statement);
    }
    return null;
  }

  @Override
  public V get(R ref, K id) {
    Connection conn = null;
    PreparedStatement statement = null;
    try {
      conn = dataSource.getConnection();
      statement = conn.prepareStatement(sqlBuilder.selectByForeignPrimary);
      statement.setObject(1, ref);
      statement.setObject(2, id);
      int rowNum = 0;
      ResultSet rs = statement.executeQuery();
      if (rs.next()) {
        return mapRow(rs, rowNum++);
      }
    } catch (Exception e) {
      logger.error("execute error", e);
    } finally {
      close(conn, statement);
    }
    return null;
  }

  @Override
  public Map<K, V> getByPrimarys(Set<K> ids) {
    Map<K, V> result = new HashMap<>(ids.size(), 1);
    Connection conn = null;
    PreparedStatement statement = null;
    try {
      conn = dataSource.getConnection();
      statement = conn.prepareStatement(sqlBuilder.getByPrimarys(ids.size()));
      {
        int i = 1;
        for (K id : ids) {
          statement.setObject(i++, id);
        }
      }
      int rowNum = 0;
      ResultSet rs = statement.executeQuery();
      if (rs.next()) {
        V value = mapRow(rs, rowNum++);
        result.put(operator.getPrimary(value), value);
      }
    } catch (Exception e) {
      logger.error("execute error", e);
    } finally {
      close(conn, statement);
    }
    return result;
  }

  @Override
  public List<V> getByForeign(R ref) {
    if (ref == null) {
      return getAll();
    }

    List<V> result = new ArrayList<>();

    Connection conn = null;
    PreparedStatement statement = null;
    try {
      conn = dataSource.getConnection();
      statement = conn.prepareStatement(sqlBuilder.selectByForeign);
      statement.setObject(1, ref);
      int rowNum = 0;
      ResultSet rs = statement.executeQuery();
      while (rs.next()) {
        result.add(mapRow(rs, rowNum++));
      }
    } catch (Exception e) {
      logger.error("execute error", e);
    } finally {
      close(conn, statement);
    }
    return result;
  }

  @Override
  public Map<K, V> getMapByForeign(R ref) {
    List<V> list = getByForeign(ref);
    Map<K, V> result = new ConcurrentHashMap<>(list.size());
    for (V v : list) {
      K key = operator.getPrimary(v);
      result.put(key, v);
    }
    return result;
  }

  @Override
  public V getByUnique(Map<String, ?> index) {
    Connection conn = null;
    PreparedStatement statement = null;
    try {
      conn = dataSource.getConnection();
      statement = conn.prepareStatement(sqlBuilder.getByIndex(index.keySet()));
      {
        int i = 1;
        for (String entry : index.keySet()) {
          statement.setObject(i++, index.get(entry));
        }
      }

      int rowNum = 0;
      ResultSet rs = statement.executeQuery();
      if (rs.next()) {
        return mapRow(rs, rowNum++);
      }
    } catch (Exception e) {
      logger.error("execute error", e);
    } finally {
      close(conn, statement);
    }
    return null;
  }

  @Override
  public List<V> getsByFulltext(Map<String, ?> index) {
    List<V> result = new ArrayList<>();

    Connection conn = null;
    PreparedStatement statement = null;
    try {
      conn = dataSource.getConnection();
      statement = conn.prepareStatement(sqlBuilder.getByIndex(index.keySet()));
      {
        int i = 1;
        for (String entry : index.keySet()) {
          statement.setObject(i++, index.get(entry));
        }
      }
      int rowNum = 0;
      ResultSet rs = statement.executeQuery();
      while (rs.next()) {
        result.add(mapRow(rs, rowNum++));
      }
    } catch (Exception e) {
      logger.error("execute error", e);
    } finally {
      close(conn, statement);
    }
    return result;
  }

  @Override
  public List<V> getAll() {
    List<V> result = new ArrayList<>();

    Connection conn = null;
    PreparedStatement statement = null;
    try {
      conn = dataSource.getConnection();
      statement = conn.prepareStatement(sqlBuilder.selectAll);
      int rowNum = 0;
      ResultSet rs = statement.executeQuery();
      while (rs.next()) {
        result.add(mapRow(rs, rowNum++));
      }
    } catch (Exception e) {
      logger.error("execute error", e);
    } finally {
      close(conn, statement);
    }
    return result;
  }

  @Override
  public Map<K, V> getMapAll() {
    List<V> list = getAll();
    Map<K, V> result = new HashMap<>(list.size(), 1);
    for (V v : list) {
      K key = operator.getPrimary(v);
      result.put(key, v);
    }
    return result;
  }

  @Override
  public <T> T query(String sql, RowMapper<T> mapper, List params) {
    Connection conn = null;
    PreparedStatement statement = null;
    try {
      conn = dataSource.getConnection();
      statement = conn.prepareStatement(sql);
      {
        int i = 1;
        for (Object param : params) {
          statement.setObject(i++, param);
        }
      }
      int rowNum = 0;
      ResultSet rs = statement.executeQuery();
      if (rs.next()) {
        return mapper.mapRow(rs, rowNum++);
      }
    } catch (Exception e) {
      logger.error("execute error", e);
    } finally {
      close(conn, statement);
    }
    return null;
  }

  @Override
  public <T> List<T> queryList(String sql, RowMapper<T> mapper, List params) {
    List<T> result = new ArrayList<>();

    Connection conn = null;
    PreparedStatement statement = null;
    try {
      conn = dataSource.getConnection();
      statement = conn.prepareStatement(sql);
      {
        int i = 1;
        for (Object param : params) {
          statement.setObject(i++, param);
        }
      }
      int rowNum = 0;
      ResultSet rs = statement.executeQuery();
      while (rs.next()) {
        result.add(mapper.mapRow(rs, rowNum++));
      }
    } catch (Exception e) {
      logger.error("execute error", e);
    } finally {
      close(conn, statement);
    }
    return result;
  }

  @Override
  public List<Map<String, Object>> queryMapList(String sql, List params) {
    List<Map<String, Object>> result = new ArrayList<>();

    Connection conn = null;
    PreparedStatement statement = null;
    try {
      conn = dataSource.getConnection();
      statement = conn.prepareStatement(sql);
      {
        int i = 1;
        for (Object param : params) {
          statement.setObject(i++, param);
        }
      }
      ResultSet rs = statement.executeQuery();
      ResultSetMetaData metaData = rs.getMetaData();
      int columnCount = metaData.getColumnCount();
      while (rs.next()) {
        Map<String, Object> map = new HashMap<>(columnCount, 1);
        {
          for (int i = 0; i < columnCount; i++) {
            String columnName = metaData.getColumnName(i + 1);
            Object columnValue = rs.getObject(i + 1);
            map.put(columnName, columnValue);
          }
        }
        result.add(map);
      }
    } catch (Exception e) {
      logger.error("execute error", e);
    } finally {
      close(conn, statement);
    }
    return result;
  }

  @Override
  public int delete(Map<String, Object> index) {
    String sql = sqlBuilder.delete(index.keySet());
    Connection conn = null;
    PreparedStatement statement = null;
    try {
      conn = dataSource.getConnection();
      statement = conn.prepareStatement(sql);
      {
        int i = 1;
        for (String entry : index.keySet()) {
          statement.setObject(i++, index.get(entry));
        }
      }
      return statement.executeUpdate();
    } catch (SQLException e) {
      logger.error("execute delete error sql:" + sql + " param:" + index + "", e);
    } finally {
      close(conn, statement);
    }
    return 0;
  }

  @Override
  public long countByFulltext(Map<String, Object> index) {
    return query(
        sqlBuilder.count(index.keySet()),
        new RowMapper<Long>() {
          @Override
          public Long mapRow(ResultSet rs, int rowNum) throws Exception {
            return rs.getLong(1);
          }
        },
        Lists.newArrayList(index.values()));
  }

  @Override
  public List<V> pageByFulltext(Map<String, Object> index, int pageSize, int startNum) {
    List<Object> params = new ArrayList<>(index.size() + 2);
    for (Object param : index.values()) {
      params.add(param);
    }
    params.add(startNum);
    params.add(pageSize);
    return queryList(sqlBuilder.page(index.keySet()), params);
  }

  @Override
  public List<V> pageRank(
      Map<String, Object> index, String desc, String asc, int pageSize, int startNum) {
    List<Object> params = new ArrayList<>(index.size() + 2);
    for (Object param : index.values()) {
      params.add(param);
    }
    params.add(startNum);
    params.add(pageSize);
    return queryList(sqlBuilder.pageRank(index.keySet(), desc, asc), params);
  }

  @Override
  public void checkDatabaseTableWithEntity() {
    entityTableChecker.check();
  }

  @Override
  public List<V> queryList(String sql, List params) {
    return this.queryList(sql, this, params);
  }

  @Override
  public List<V> queryListByWhere(String where, List params) {
    return this.queryList(sqlBuilder.selectAll + " " + where, this, params);
  }

  @Override
  public boolean update(V record) {
    Connection conn = null;
    PreparedStatement statement = null;
    try {
      conn = dataSource.getConnection();
      statement = conn.prepareStatement(sqlBuilder.update);
      for (int i = 1; i < operator.fields.size(); i++) {
        Field field = operator.fields.get(i);
        Object o = null;

        if (field.getType().equals(JSONObject.class) || field.getType().equals(JSONArray.class)) {
          o = operator.fields.get(i).get(record).toString();
        } else {
          o = operator.fields.get(i).get(record);
        }

        statement.setObject(i, o);
      }
      statement.setObject(operator.fields.size(), operator.primaryField.get(record));
      if (this.operator.combine) {
        statement.setObject(operator.fields.size() + 1, operator.foreignField.get(record));
      }
      int result = statement.executeUpdate();
      return result == 1;
    } catch (Exception e) {
      logger.error("execute error", e);
    } finally {
      close(conn, statement);
    }
    return false;
  }

  @Override
  public boolean delete(V record) {
    K id = operator.getPrimary(record);

    Connection conn = null;
    PreparedStatement statement = null;
    try {
      conn = dataSource.getConnection();
      statement = conn.prepareStatement(sqlBuilder.delete);

      statement.setObject(1, id);
      if (this.operator.combine) {
        R ref = operator.getForeign(record);
        statement.setObject(2, ref);
      }
      return statement.executeUpdate() == 1;
    } catch (SQLException e) {
      logger.error(
          "execute deleteByPrimary error sql:" + sqlBuilder.delete + " param:" + id + "", e);
    } finally {
      close(conn, statement);
    }
    return false;
  }

  @Override
  public DataEntityOperator getEntityOperator() {
    return this.operator;
  }

  @Override
  public V mapRow(ResultSet rs, int rowNum) {
    try {
      V v = operator.newInstance();
      for (int i = 0; i < operator.fields.size(); i++) {
        Field field = operator.fields.get(i);
        if (field.getType().isPrimitive() && rs.getObject(operator.fieldNames.get(i)) == null) {
          field.set(v, getTypeDefaultValue(field.getType()));
        } else {

          Object object = rs.getObject(operator.fieldNames.get(i));

          if (field.getType().equals(JSONObject.class)) {
            field.set(v, JSONObject.parseObject(object.toString()));
          } else if (field.getType().equals(JSONArray.class)) {
            field.set(v, JSONArray.parseArray(object.toString()));
          } else {
            field.set(v, object);
          }
        }
      }
      return v;
    } catch (Exception e) {
      logger.error("mapRow error", e);
    }
    return null;
  }

  private final Object getTypeDefaultValue(Class<?> type) {
    if (type == Boolean.TYPE) {
      return false;
    }

    if (type == Integer.TYPE) {
      return 0;
    }

    if (type == Float.TYPE) {
      return 0.0f;
    }
    if (type == Long.TYPE) {
      return 0L;
    }
    if (type == Double.TYPE) {
      return 0.0d;
    }

    if (type == JSONArray.class) {
      return new JSONArray();
    }
    if (type == JSONPObject.class) {
      return new JSONPObject();
    }

    throw new IllegalArgumentException("Not primitive type : " + type.getName());
  }

  public <T> T execute(final String sql, final PreparedStatementCallback<T> action) {
    return execute(
        new PreparedStatementCreator() {
          @Override
          public PreparedStatement createPreparedStatement(Connection con) throws SQLException {
            return con.prepareStatement(sql);
          }
        },
        action);
  }

  public <T> T execute(PreparedStatementCreator psc, PreparedStatementCallback<T> action) {
    Connection conn = null;
    PreparedStatement statement = null;
    try {
      conn = dataSource.getConnection();
      statement = psc.createPreparedStatement(conn);
      return action.doInPreparedStatement(statement);
    } catch (SQLException e) {
      logger.error("execute error", e);
      return null;
    } finally {
      close(conn, statement);
    }
  }

  protected static void close(Connection conn, PreparedStatement statement) {
    if (statement != null) {
      try {
        statement.close();
      } catch (SQLException e) {
        logger.error("PreparedStatement close error", e);
      }
    }
    if (conn != null) {
      try {
        conn.close();
      } catch (SQLException e) {
        logger.error("Connection close error", e);
      }
    }
  }

  protected static Object convertValueToRequiredType(Object value, Class requiredType) {
    if (String.class.equals(requiredType)) {
      return value.toString();
    } else if (Number.class.isAssignableFrom(requiredType)) {
      if (value instanceof Number) {
        // Convert original Number to target Number class.
        return NumberUtils.convertNumberToTargetClass(((Number) value), requiredType);
      } else {
        // Convert stringified value to target Number class.
        return NumberUtils.parseNumber(value.toString(), requiredType);
      }
    } else {
      throw new IllegalArgumentException(
          "Value ["
              + value
              + "] is of type ["
              + value.getClass().getName()
              + "] and cannot be converted to required type ["
              + requiredType.getName()
              + "]");
    }
  }
}
