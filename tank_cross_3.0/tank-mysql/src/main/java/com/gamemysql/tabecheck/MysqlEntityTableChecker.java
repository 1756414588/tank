package com.gamemysql.tabecheck;

import com.alibaba.fastjson.JSONObject;
import com.gamemysql.annotation.Column;
import com.gamemysql.annotation.EntityField;
import com.gamemysql.annotation.Primary;
import com.gamemysql.annotation.Table;
import com.gamemysql.core.StringUtil;
import com.gamemysql.core.sql.SqlExpert;
import com.google.common.base.CaseFormat;
import com.google.common.base.Preconditions;
import org.apache.log4j.Logger;

import javax.sql.DataSource;
import java.lang.reflect.Field;
import java.sql.*;
import java.util.*;

/** 检测数据库表结构 */
public class MysqlEntityTableChecker implements EntityTableChecker {

  public static Logger logger = Logger.getLogger("ERROR");

  private final DataSource dataSource;

  private final Class<?> entityClass;

  private final SqlExpert sqlExpert;

  public MysqlEntityTableChecker(DataSource dataSource, Class<?> entityClass, SqlExpert sqlExpert) {
    this.dataSource = dataSource;
    this.entityClass = entityClass;
    this.sqlExpert = sqlExpert;
  }

  private Connection getConnection() {
    try {
      return dataSource.getConnection();
    } catch (SQLException e) {
      logger.error(e.getMessage(), e);
      throw new DataException(e);
    }
  }

  private boolean isTableExist(Connection connection, String tableName) throws SQLException {
    ResultSet tableRs =
        connection.getMetaData().getTables(null, null, tableName, new String[] {"TABLE"});
    return tableRs.next();
  }

  /** 校验数据库 */
  @Override
  public boolean check() {
    Connection connection = getConnection();
    try {
      return check(connection);
    } finally {
      if (connection != null) {
        try {
          connection.close();
        } catch (SQLException e) {
          logger.error(e.getMessage(), e);
        }
      }
    }
  }

  /**
   * 检查表结构
   *
   * @param connection
   * @return
   */
  private boolean check(Connection connection) {

    Class<?> cls = entityClass;

    Table table = cls.getAnnotation(Table.class);

    Preconditions.checkNotNull(table, "实体类 %s 上，没有@Table", cls.getName());

    String tableName = table.value();

    logger.info("开始校验数据库表[" + tableName + "]");

    Field[] srcFields = cls.getDeclaredFields();

    // 过滤掉 @EntityField 注解的字段
    List<Field> fieldList = new ArrayList<>();
    List<String> fieldColumns = new ArrayList<>();
    fieldColumns.add("log_update_time");
    for (Field field : srcFields) {
      if (field.getAnnotation(EntityField.class) == null) {
        fieldList.add(field);
      }
      if (field.getAnnotation(Column.class) != null) {
        fieldColumns.add(sqlExpert.getColumnName(field));
      }
    }

    // 找不到相应的表
    TableMetaData tableMetaData = null;

    try {

      boolean isTableExist = isTableExist(connection, tableName);
      if (isTableExist) {
        tableMetaData = new TableMetaData(connection.getMetaData(), tableName);
      }

    } catch (SQLException e) {
      logger.error(e.getMessage(), e);
    }

    if (tableMetaData == null) {
      String sql = sqlExpert.genCreateTableSql(table, fieldList);

      logger.info(
          "[" + cls.getSimpleName() + "]实体对应的表[" + tableName + "]找不到,自动创建表结构，SQL:\n\n" + sql + "");

      try {
        // 有索引时，sql不能一起执行，得先执行建表完成，再创建索引
        List<String> sqlList = StringUtil.SPLITTER_INDEX_SELF.splitToList(sql);
        for (String s : sqlList) {
          connection.prepareStatement(s).execute();
        }
      } catch (SQLException e) {
        logger.error("自动创建表失败," + tableName, e);
        throw new DataException(e);
      }
    } else {

      // 没有主键
      if (tableMetaData.getPrimaryColumnsCount() == 0) {
        logger.error("数据库错误,[{" + tableName + "}]表没有主键，程序即将退出");
        return false;
      }

      // 数据库表字段和实体属性的数量不一致,+1 是加上update_time
      if (tableMetaData.getColumnCount() > fieldList.size() + 1) {
        tableMetaData.getAllColumns().removeAll(fieldColumns);
        logger.error(
            "数据库表字段和实体属性的数量不一致,[{"
                + cls.getSimpleName()
                + "}]实体的属性个数为[{"
                + fieldList.size()
                + "}], [{"
                + tableName
                + "}]表的字段个数为[{"
                + tableMetaData.getColumnCount()
                + "}],多了字段:{"
                + JSONObject.toJSONString(tableMetaData.getAllColumns())
                + "}");
        return false;
      }

      // 一般不会有这种情况，除非这个表是手动创建的
      if (!tableMetaData.contains("log_update_time")) {
        String sql = sqlExpert.genAddUpdateTimeColumnSql(table);
        logger.info(
            "数据库错误,实体中的字段[{" + tableName + "}]在表[{log_update_time}]中不存在，自动修补，sql:{" + sql + "}");
        try {
          connection.prepareStatement(sql).execute();
        } catch (SQLException e) {
          logger.error("自动修补表失败", e);
          throw new DataException(e);
        }
      }

      Map<String, String> fieldColumn = new HashMap<>();
      for (Field field : fieldList) {
        Column column = field.getAnnotation(Column.class);
        if (column == null) {
          logger.info(
              "警告警告,实体[{"
                  + cls.getSimpleName()
                  + "}]的字段[{"
                  + field.getName()
                  + "}]未加column注解,如果不对应数据库中的字段，请加@EntityField注解");
          continue;
        }

        Primary primary = field.getAnnotation(Primary.class);
        if (primary != null && !tableMetaData.primaryKeyExist(column.value())) {
          logger.info(
              "实体[{"
                  + cls.getSimpleName()
                  + "}]的主键[{"
                  + column.value()
                  + "}]不是表[{"
                  + tableName
                  + "}]中的主键");
        }

        // if(field.getType().isPrimitive() && column.nullable() &&
        // primary==null){
        // logger.error("实体类 {} 中的属性{} 是基础类，却允许null；加上nullable=false",
        // cls.getSimpleName(),field.getName());
        // throw new DataException();
        // }
        String fieldName = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, column.value());
        // if(!fieldName.equals(field.getName())){
        // logger.warn("实体类 {} 中的属性{} ,对应数据库中的字段{},不符合命名规范",
        // cls.getSimpleName(),field.getName(),column.value());
        // }

        // if(!fieldName.equalsIgnoreCase(field.getName())){
        // logger.error("实体类 {} 中的属性{} ,对应数据库中的字段{},不匹配",
        // cls.getSimpleName(),field.getName(),column.value());
        // throw new DataException();
        // }
        if (fieldColumn.containsKey(fieldName) || fieldColumn.containsValue(column.value())) {
          logger.error(
              "实体类 {"
                  + cls.getSimpleName()
                  + "} 中的属性{"
                  + field.getName()
                  + "} ,对应数据库中的字段{"
                  + column.value()
                  + "},有重复匹配");
          throw new DataException("实体类中多个属性同时映射了同一个字段");
        }
        fieldColumn.put(fieldName, column.value());

        if (!tableMetaData.contains(column.value())) {
          String sql = sqlExpert.genAddTableColumnSql(table, field);
          logger.info(
              "数据库错误,实体中的字段[{"
                  + column.value()
                  + "}]在表[{"
                  + tableName
                  + "}]中不存在，自动修补，sql:{"
                  + sql
                  + "}");
          try {
            connection.prepareStatement(sql).execute();
            fieldColumn.put(fieldName, column.value());
            if (column.index()) {
              sql = sqlExpert.genCreateIndexSql(tableName, column.value());
              connection.prepareStatement(sql).execute();
            }
            continue;
          } catch (SQLException e) {
            logger.error("自动修补表失败", e);
            throw new DataException(e);
          }
        }
        ColumnMetaData columnDate = tableMetaData.getColumn(column.value());
        // 相同类型时，长度变长了，修改长度
        if (columnDate.isSameType(field.getType())
            && columnDate.getColumnSize() < column.length()) {
          String sql = sqlExpert.genModifyTableColumnSql(table, field);
          logger.info(
              "数据库错误,实体{"
                  + tableName
                  + "}中的字段[{"
                  + column.value()
                  + "}]长度不够，自动增长，原长度:{"
                  + columnDate.getColumnSize()
                  + "} 增长到:{"
                  + column.length()
                  + "} sql:{"
                  + sql
                  + "}");
          try {
            connection.prepareStatement(sql).execute();
          } catch (SQLException e) {
            logger.error("自动增长失败", e);
            throw new DataException(e);
          }
        }

        // 这是先有数据表，再写实体类时，实体类限制不严格
        if (columnDate.getSqlTypeName().equalsIgnoreCase("text") && column.length() < 65535) {
          logger.error(
              "实体类 {"
                  + cls.getSimpleName()
                  + "} 中的属性{"
                  + field.getName()
                  + "} 对应数据库中类型是text，但没有标识length=65535;@Column(value=\"{"
                  + column.value()
                  + "}\",length=65535)");
          throw new DataException("对应数据库中类型是text，但没有标识length=65535");
        }

        // index
        String indexName = tableMetaData.getIndexColumns().get(column.value());
        String sql = null;
        if (indexName != null) {
          if (indexName.startsWith("INDEX_UN_")) {
            if (!column.unique()) {
              sql = sqlExpert.genDropUnIndexSql(tableName, column.value());
            }
          } else if (!column.index()) {
            sql = sqlExpert.genDropIndexSql(tableName, column.value());
          }
          if (sql != null) {
            logger.info(
                "数据库错误,实体中的字段[{"
                    + column.value()
                    + "}]在表[{"
                    + tableName
                    + "}]中多了索引，自动删除，sql:{"
                    + sql
                    + "}");
            try {
              connection.prepareStatement(sql).execute();
            } catch (SQLException e) {
              logger.error("删除索引失败", e);
            }
          }
        } else {
          if (column.index()) {
            sql = sqlExpert.genCreateIndexSql(tableName, column.value());
          } else if (column.unique()) {
            sql = sqlExpert.genCreateUnIndexSql(tableName, column.value());
          }
          if (sql != null) {
            logger.info(
                "数据库错误,实体中的字段[{"
                    + column.value()
                    + "}]在表[{"
                    + tableName
                    + "}]中缺少索引，自动修补，sql:{"
                    + sql
                    + "}");
            try {
              connection.prepareStatement(sql).execute();
            } catch (SQLException e) {
              logger.error("修补索引失败", e);
            }
          }
        }
      }
    }
    return true;
  }
}

class TableMetaData {
  /** 过滤的数据库字段 */
  private static Set<String> columnFilters = new HashSet<>();

  static {
    // columnFilters.add("log_update_time");
  }

  private DatabaseMetaData dbMetaData;

  private String tableName;
  private int columnCount = 0;

  private Map<String, ColumnMetaData> primaryColumns = new HashMap<>();

  private Map<String, ColumnMetaData> otherColumns = new HashMap<>();

  private List<String> allColumns = new ArrayList<>();

  /** 索引字段 */
  private Map<String, String> indexColumns = new HashMap<>();

  public TableMetaData(DatabaseMetaData dbMetaData, String tableName) {
    this.dbMetaData = dbMetaData;
    this.tableName = tableName;
    try {
      initialize();
    } catch (SQLException e) {
      e.printStackTrace();
    }
  }

  private void initialize() throws SQLException {

    // get primarykeys
    List<String> primaryKeys = new ArrayList<String>();
    ResultSet primaryColumnRs = dbMetaData.getPrimaryKeys(null, null, tableName);
    while (primaryColumnRs.next()) {
      String cName = primaryColumnRs.getString("COLUMN_NAME");
      primaryKeys.add(cName);
    }

    // build all columns
    ResultSet columnRs = dbMetaData.getColumns(null, null, tableName, "%");
    while (columnRs.next()) {
      String column = columnRs.getString("COLUMN_NAME");
      // 过滤掉不需要搭理的列
      if (columnFilters.contains(column)) {
        continue;
      }

      int sqlType = columnRs.getInt("DATA_TYPE");
      String sqlTypeName = columnRs.getString("TYPE_NAME");
      int columnSize = columnRs.getInt("COLUMN_SIZE");
      String defaultValue = columnRs.getString("COLUMN_DEF");
      ColumnMetaData cMetaData =
          new ColumnMetaData(column, columnSize, sqlType, sqlTypeName, defaultValue);
      if (primaryKeys.contains(column)) {
        primaryColumns.put(column, cMetaData);
      } else {
        otherColumns.put(column, cMetaData);
      }
      allColumns.add(column);
      columnCount++;
    }

    ResultSet indexRs = dbMetaData.getIndexInfo(null, null, tableName, false, false);
    while (indexRs.next()) {
      String columnName = indexRs.getString("COLUMN_NAME"); // 列名
      if (primaryColumns.containsKey(columnName)) {
        continue;
      }
      String indexName = indexRs.getString("INDEX_NAME"); // 索引的名称
      indexColumns.put(columnName, indexName);
      //			boolean nonUnique = indexRs.getBoolean("NON_UNIQUE");// 非唯一索引(Can
      //																	// index
      //																	// values be
      //																	// non-unique.
      //																	// false
      //																	// when TYPE
      //																	// is
      //																	// tableIndexStatistic
      //																	// )
      //			String indexQualifier = indexRs.getString("INDEX_QUALIFIER");// 索引目录（可能为空）
      //			short type = indexRs.getShort("TYPE");// 索引类型
      //			short ordinalPosition = indexRs.getShort("ORDINAL_POSITION");// 在索引列顺序号
      //			String ascOrDesc = indexRs.getString("ASC_OR_DESC");// 列排序顺序:升序还是降序
      //			int cardinality = indexRs.getInt("CARDINALITY"); // 基数
    }
  }

  /** 获取主键数量 */
  public int getPrimaryColumnsCount() {
    return primaryColumns.size();
  }

  /** 获取主键 */
  public Set<String> getPrimaryKeys() {
    return primaryColumns.keySet();
  }

  /** 判断主键是否存在 */
  public boolean primaryKeyExist(String columnName) {
    return primaryColumns.containsKey(columnName);
  }

  /** 获取所有列的数量 */
  public int getColumnCount() {
    return columnCount;
  }

  /** 判断列名在表中是否存在 */
  public boolean contains(String columnName) {
    return primaryColumns.containsKey(columnName) || otherColumns.containsKey(columnName);
  }

  public final List<String> getAllColumns() {
    return allColumns;
  }

  public final ColumnMetaData getColumn(String columnName) {
    return com.google.common.base.Optional.fromNullable(primaryColumns.get(columnName))
        .or(com.google.common.base.Optional.fromNullable(otherColumns.get(columnName)))
        .get();
  }

  public final Map<String, String> getIndexColumns() {
    return indexColumns;
  }
}

class ColumnMetaData {

  private String column;

  private int columnSize;

  private int sqlType;

  private String sqlTypeName;

  private Object defaultValue;

  /**
   * @param column
   * @param sqlType {@link Types}
   */
  public ColumnMetaData(
      String column, int columnSize, int sqlType, String sqlTypeName, Object defaultValue) {
    this.column = column;
    this.columnSize = columnSize;
    this.sqlType = sqlType;
    this.sqlTypeName = sqlTypeName;
    this.defaultValue = defaultValue;
  }

  public String getColumn() {
    return column;
  }

  public int getSqlType() {
    return sqlType;
  }

  public String getSqlTypeName() {
    return sqlTypeName;
  }

  public int getColumnSize() {
    return columnSize;
  }

  public Object getDefaultValue() {
    return defaultValue;
  }

  public boolean isSameType(Class<?> field) {
    switch (sqlType) {
      case Types.VARCHAR:
        if (field == String.class) {
          return true;
        }

      default:
        break;
    }
    return false;
  }
}
