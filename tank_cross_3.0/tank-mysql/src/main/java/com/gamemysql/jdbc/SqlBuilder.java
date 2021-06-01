package com.gamemysql.jdbc;

import com.gamemysql.core.entity.DataEntity;
import com.gamemysql.core.entity.DataEntityOperator;
import com.google.common.base.Joiner;
import com.google.common.base.Preconditions;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

import java.util.Arrays;
import java.util.Set;
import java.util.concurrent.ConcurrentMap;

public class SqlBuilder<K, R, V extends DataEntity<K, R>> {
  private final DataEntityOperator<K, R, V> operator;

  public final String insertWithGeneratedKey; // sql insert 自增主键
  public final String insertWithKey; // sql insert 指定主键
  public final String selectByPrimary;
  public final String selectByForeign;
  public final String selectByForeignPrimary;
  public final String selectAll;
  public final String update;
  public final String delete;

  private final ConcurrentMap<Set<String>, String> selectByIndex = Maps.newConcurrentMap();
  private final ConcurrentMap<Integer, String> getByPrimarys = Maps.newConcurrentMap();

  public SqlBuilder(DataEntityOperator<K, R, V> operator) {
    this.operator = operator;
    Preconditions.checkNotNull(operator, "operator not null");
    this.insertWithGeneratedKey = insert(false);
    this.insertWithKey = insert(true);
    this.selectByPrimary =
        this.operator.primaryFieldName == null
            ? null
            : getByIndex(Sets.newHashSet(this.operator.primaryFieldName));
    this.selectByForeign =
        this.operator.foreignFieldName == null
            ? null
            : getByIndex(Sets.newHashSet(this.operator.foreignFieldName));
    this.selectByForeignPrimary =
        this.operator.primaryFieldName == null || this.operator.foreignFieldName == null
            ? null
            : getByIndex(
                Sets.newHashSet(this.operator.foreignFieldName, this.operator.primaryFieldName));
    this.selectAll = getByIndex(Sets.<String>newHashSet());
    this.update = updateByPrimary();
    this.delete = deleteByPrimary();
  }

  private String insert(boolean withKey) {
    int start = withKey ? 0 : 1;
    String[] fields = new String[this.operator.fieldNames.size() - start];
    String[] placeholders = new String[this.operator.fieldNames.size() - start];
    for (int i = 0; i < this.operator.fieldNames.size(); i++) {
      if (withKey) {
        fields[i] = "`" + this.operator.fieldNames.get(i) + "`";
        placeholders[i] = "?";
      } else {
        if (i < this.operator.primary) {
          fields[i] = "`" + this.operator.fieldNames.get(i) + "`";
          placeholders[i] = "?";
        } else if (i > this.operator.primary) {
          fields[i - start] = "`" + this.operator.fieldNames.get(i) + "`";
          placeholders[i - start] = "?";
        }
      }
    }
    return "INSERT INTO `"
        + this.operator.tableName
        + "` ("
        + Joiner.on(",").join(fields)
        + ") VALUES ("
        + Joiner.on(",").join(placeholders)
        + ")";
  }

  public String getByIndex(Set<String> index) {
    String sql = selectByIndex.get(index);
    if (sql == null) {
      if (index == null || index.isEmpty()) {
        sql = "SELECT * FROM `" + this.operator.tableName + "`";
      } else {
        String[] part = new String[index.size()];
        int i = 0;
        for (String idx : index) {
          part[i++] = "`" + idx + "`=?";
        }
        sql =
            "SELECT * FROM `"
                + this.operator.tableName
                + "` WHERE ("
                + Joiner.on(" AND ").join(part)
                + ")";
      }
      String old = selectByIndex.putIfAbsent(index, sql);
      if (old != null) {
        sql = old;
      }
    }
    return sql;
  }

  public String count(Set<String> index) {
    return "SELECT COUNT(*) FROM `" + this.operator.tableName + "`" + where(index);
  }

  public String page(Set<String> index) {
    return "SELECT * FROM `" + this.operator.tableName + "`" + where(index) + " LIMIT ?,?";
  }

  public String pageRank(Set<String> index, String desc, String asc) {
    return "SELECT * FROM `"
        + this.operator.tableName
        + "`"
        + where(index)
        + order(desc, asc)
        + " LIMIT ?,?";
  }

  public String where(Set<String> index) {
    String sql;
    if (index == null || index.isEmpty()) {
      sql = "";
    } else {
      String[] part = new String[index.size()];
      int i = 0;
      for (String idx : index) {
        part[i++] = "`" + idx + "`=?";
      }
      sql = " WHERE (" + Joiner.on(" AND ").join(part) + ")";
    }
    return sql;
  }

  public String order(String desc, String asc) {
    String sql = " ";
    if (desc != null || asc != null) {
      sql += "order by ";
    }
    if (desc != null) {
      sql += desc + " desc ";
    }

    if (asc != null) {
      if (sql.contains("desc")) {
        sql += "," + asc + " asc";
      } else {
        sql += asc + " asc";
      }
    }
    return sql;
  }

  public String delete(Set<String> index) {
    return "DELETE FROM `" + this.operator.tableName + "`" + where(index);
  }

  public String getByPrimarys(int num) {
    String sql = getByPrimarys.get(num);
    if (sql == null) {
      if (num == 1) {
        sql = getByIndex(Sets.newHashSet(this.operator.primaryFieldName));
      } else {
        String[] placeholders = new String[num];
        Arrays.fill(placeholders, "?");
        sql =
            "SELECT * FROM `Test` WHERE `"
                + this.operator.primaryFieldName
                + "` IN ("
                + Joiner.on(",").join(placeholders)
                + ")";
      }
      String old = getByPrimarys.putIfAbsent(num, sql);
      if (old != null) {
        sql = old;
      }
    }
    return sql;
  }

  private String updateByPrimary() {
    String[] part = new String[this.operator.fieldNames.size() - 1];
    for (int i = 1; i < this.operator.fieldNames.size(); i++) {
      part[i - 1] = "`" + this.operator.fieldNames.get(i) + "`=?";
    }
    if (this.operator.combine) {
      return "UPDATE `"
          + this.operator.tableName
          + "` SET "
          + Joiner.on(",").join(part)
          + " WHERE (`"
          + this.operator.primaryFieldName
          + "`=? AND `"
          + this.operator.foreignFieldName
          + "`=?)";
    } else {
      return "UPDATE `"
          + this.operator.tableName
          + "` SET "
          + Joiner.on(",").join(part)
          + " WHERE (`"
          + this.operator.primaryFieldName
          + "`=?)";
    }
  }

  private String deleteByPrimary() {
    if (this.operator.combine) {
      return "DELETE FROM `"
          + this.operator.tableName
          + "` WHERE (`"
          + this.operator.primaryFieldName
          + "`=? AND `"
          + this.operator.foreignFieldName
          + "`=?)";
    } else {
      return "DELETE FROM `"
          + this.operator.tableName
          + "` WHERE (`"
          + this.operator.primaryFieldName
          + "`=?)";
    }
  }
}
