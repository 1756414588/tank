/**
 *
 */
package com.gamemysql.core.sql;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.gamemysql.annotation.Column;
import com.gamemysql.annotation.Primary;
import com.gamemysql.annotation.Table;
import com.gamemysql.core.StringUtil;
import com.google.common.base.CaseFormat;
import org.apache.log4j.Logger;

import java.lang.reflect.Field;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class MysqlSqlExpert implements SqlExpert {

    public static Logger logger = Logger.getLogger("ERROR");

    /**
     * 根据字段 获取对应数据库类型
     *
     * @param field
     * @param column
     * @return
     */
    private String evalFieldType(Field field, Column column) {
        Class<?> type = field.getType();
        if (type == String.class || type == JSONObject.class || type == JSONArray.class) {
            if (column.length() == Integer.MAX_VALUE) {
                return "LONGTEXT";
            } else if (column.length() >= 65535) {
                return "TEXT";
            } else {
                return "VARCHAR(" + column.length() + ")";
            }
        }

        if (type == Integer.class || type == int.class) {
            return "INT(11)";
        }

        if (type == Long.class || type == long.class) {
            return "BIGINT(20)";
        }

        if (type == Float.class || type == float.class) {
            return "FLOAT(" + column.precision() + "," + column.scale() + ")";
        }
        if (type == Double.class || type == double.class) {
            return "DOUBLE(" + column.precision() + "," + column.scale() + ")";
        }
        if (type == Date.class || type == Timestamp.class) {
            return "TIMESTAMP";
        }
        if (type == byte[].class) {
            if (column.length() >= 65535) {
                return "mediumBlob";
            }
            if (column.length() == -1) {
                return "LongBlob";
            }
            return "blob";
        }
        if (type == Boolean.class || type == boolean.class) {
            return "TINYINT(1)";
        }

        logger.error(
                "未实现的Java属性转Mysql类型,field:{" + field.getName() + "},column:{" + column.value() + "}");
        throw new RuntimeException("未实现的Java属性转Mysql类型：" + type);
    }

    /**
     * 获取注解的表字段名称，如果没有 value 使用自定名称
     *
     * @param field
     * @return
     */
    @Override
    public String getColumnName(Field field) {
        Column column = field.getAnnotation(Column.class);
        if (column == null) {
            throw new RuntimeException(field.getName() + "没有注解Column");
        }
        String columnName = column.value();
        if (columnName == null) { // 如果没有设置value值，转换属性名字
            columnName = CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, field.getName());
        }
        return columnName;
    }

    /**
     * 在表上创建一个简单的索引。允许使用重复的值
     *
     * @param tableName
     * @param columnName
     * @return
     */
    @Override
    public String genCreateIndexSql(String tableName, String columnName) {
        return "CREATE INDEX INDEX_"
                + tableName
                + "_"
                + columnName
                + " ON "
                + tableName
                + " ("
                + columnName
                + ");";
    }

    @Override
    public String genCreateUnIndexSql(String tableName, String columnName) {
        return "CREATE INDEX INDEX_UN_"
                + tableName
                + "_"
                + columnName
                + "  ON "
                + tableName
                + "("
                + columnName
                + ");";
    }

    @Override
    public String genDropIndexSql(String tableName, String columnName) {
        return "DROP INDEX INDEX_" + tableName + "_" + columnName + "  ON " + tableName + ";";
    }

    @Override
    public String genDropUnIndexSql(String tableName, String columnName) {
        return "DROP INDEX INDEX_UN_" + tableName + "_" + columnName + "  ON " + tableName + ";";
    }

    /**
     * 生成创建数据库表的sql
     *
     * @param table
     * @param columnFileds
     * @return
     */
    @Override
    public String genCreateTableSql(Table table, List<Field> columnFileds) {
        StringBuilder sb = new StringBuilder(512);
        sb.append("CREATE TABLE `" + table.value() + "` (");
        String primaryKey = null;
        List<String> uniqueColumns = new ArrayList<>();
        List<String> indexColumns = new ArrayList<>();
        for (Field field : columnFileds) {
            Column column = field.getAnnotation(Column.class);
            String columnName = getColumnName(field);
            sb.append('\n').append('`').append(columnName).append('`');
            sb.append(' ').append(evalFieldType(field, column));
            Primary primary = field.getAnnotation(Primary.class);
            if (primary != null) {
                primaryKey = columnName;
                sb.append(" UNIQUE NOT NULL");
                if (primary.strategy() == Primary.GenerationType.AUTO) {
                    sb.append(" AUTO_INCREMENT");
                }
            } else {
                if (column.unique()) {
                    uniqueColumns.add(columnName);
                }
                if (!column.nullable()) {
                    sb.append(" NOT NULL");
                } else {
                    if (field.getType() == Date.class || field.getType() == Timestamp.class) {
                        if ("".equals(column.defaultValue())) {
                            sb.append(" NULL DEFAULT NULL");
                        }
                    }
                }
                if (!"".equals(column.defaultValue())) {
                    sb.append(" DEFAULT '").append(column.defaultValue()).append("'");
                }
                if (!"".equals(column.comment())) {
                    sb.append(" COMMENT '").append(column.comment()).append("'");
                }
            }
            sb.append(',');

            if (column.index()) {
                indexColumns.add(columnName);
            }
        }
        sb.append('\n')
                .append(
                        "`log_update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,");
        if (!uniqueColumns.isEmpty()) {
            for (String c : uniqueColumns) {
                sb.append('\n');
                sb.append("UNIQUE KEY `INDEX_");
                sb.append("UN_")
                        .append(table.value())
                        .append("_")
                        .append(c)
                        .append('`')
                        .append(" (`")
                        .append(c)
                        .append("`)")
                        .append(',');
            }
        }
        if (primaryKey != null) {
            sb.append('\n');
            sb.append("PRIMARY KEY (");
            sb.append('`').append(primaryKey).append("`)");
            sb.append("\n ");
        }
        sb.setCharAt(sb.length() - 1, ')');

        sb.append(" ENGINE=").append(table.engine().name());
        sb.append(" DEFAULT CHARSET=utf8");
        if (!"".equals(table.comment())) {
            sb.append(" COMMENT='").append(table.comment()).append("'");
        }

        if (!indexColumns.isEmpty()) {
            sb.append(";\n");
            for (String columnName : indexColumns) {
                sb.append(StringUtil.SPLITER_INDEX_STRING);
                sb.append(genCreateIndexSql(table.value(), columnName));
                sb.append('\n');
            }
        }
        return sb.toString();
    }

    @Override
    public String genAddUpdateTimeColumnSql(Table table) {
        StringBuilder sb = new StringBuilder(128);
        sb.append("ALTER TABLE `")
                .append(table.value())
                .append("` ADD COLUMN ")
                .append(
                        "`log_update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP");
        return sb.toString();
    }

    /**
     * 自动添加表字段 sql
     *
     * @param table
     * @param field
     * @return
     */
    @Override
    public String genAddTableColumnSql(Table table, Field field) {
        StringBuilder sb = new StringBuilder(128);
        Column column = field.getAnnotation(Column.class);
        String columnName = getColumnName(field);
        sb.append("ALTER TABLE `").append(table.value()).append("` ADD COLUMN `").append(columnName);
        sb.append("` ").append(evalFieldType(field, column));
        if (!column.nullable()) {
            sb.append(" NOT NULL");
        }
        if (!"".equals(column.defaultValue())) {
            sb.append(" DEFAULT '").append(column.defaultValue()).append("'");
        }
        if (!"".equals(column.comment())) {
            sb.append(" COMMENT '").append(column.comment()).append("'");
        }
        return sb.toString();
    }

    /**
     * 修改表类型
     *
     * @param table
     * @param field
     * @return
     */
    @Override
    public String genModifyTableColumnSql(Table table, Field field) {
        StringBuilder sb = new StringBuilder(128);
        Column column = field.getAnnotation(Column.class);
        String columnName = getColumnName(field);
        sb.append("ALTER TABLE  `")
                .append(table.value())
                .append("` MODIFY COLUMN `")
                .append(columnName);
        sb.append("` ").append(evalFieldType(field, column));
        if (!column.nullable()) {
            sb.append(" NOT NULL");
        }

        if (!"".equals(column.defaultValue())) {
            sb.append(" DEFAULT ").append(column.defaultValue()).append("");
        }
        if (!"".equals(column.comment())) {
            sb.append(" COMMENT '").append(column.comment()).append("'");
        }
        return sb.toString();
    }

    @Override
    public String genCreateDatabaseSql(String databaseName) {
        StringBuilder sb = new StringBuilder("CREATE DATABASE IF NOT EXISTS ");
        sb.append(databaseName);
        sb.append(" DEFAULT CHARSET utf8");
        return sb.toString();
    }
}
