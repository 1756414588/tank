package com.gamemysql.core.entity;

import com.gamemysql.annotation.Column;
import com.gamemysql.annotation.Foreign;
import com.gamemysql.annotation.Primary;
import com.gamemysql.annotation.Table;
import com.google.common.base.Preconditions;
import com.google.common.collect.ImmutableList;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 15:27 @Description :java类作用描述
 */
public class DataEntityOperator<K, R, V extends DataEntity<K, R>> {

  public final Class<V> entityClass; // 实体类型
  public final Table.FeatchType featchType;
  public final String tableName;
  public final ImmutableList<Field> fields;
  public final ImmutableList<String> fieldNames;

  public final int primary; // 主键索引
  public final Field primaryField;
  public final Class<K> primaryClass;
  public final String primaryFieldName;
  public final int foreign;
  public final Field foreignField;
  public final String foreignFieldName;
  public final boolean combine;

  public DataEntityOperator(Class<V> entityClass) {
    this.entityClass = entityClass;
    final Table table = entityClass.getAnnotation(Table.class);
    Preconditions.checkNotNull(table, "实体类 %s 上，没有@Table", entityClass.getName());
    this.tableName = table.value();
    this.featchType = table.fetch();
    Field[] fields = entityClass.getDeclaredFields();
    List<Field> fieldList = new ArrayList<>(fields.length);
    List<String> fieldNameList = new ArrayList<>(fields.length);
    int primary = -1;
    int foreign = -1;
    for (Field field : fields) {
      Primary primaryAnnotation = field.getAnnotation(Primary.class);
      Foreign foreignAnnotation = field.getAnnotation(Foreign.class);
      Column fieldAnnotation = field.getAnnotation(Column.class);
      if (fieldAnnotation != null) {
        field.setAccessible(true);

        fieldList.add(field);
        fieldNameList.add(fieldAnnotation.value());

        if (primaryAnnotation != null) {
          primary = fieldList.size() - 1;
        }

        if (foreignAnnotation != null) {
          foreign = fieldList.size() - 1;
        }
      }
    }

    this.fields = ImmutableList.copyOf(fieldList);
    this.fieldNames = ImmutableList.copyOf(fieldNameList);
    this.primary = primary;
    this.primaryField = fieldList.get(primary);
    this.primaryClass = (Class<K>) fieldList.get(primary).getGenericType();
    this.primaryFieldName = fieldNameList.get(primary);
    this.foreign = foreign;
    if (foreign == -1) {
      this.foreignField = null;
      this.foreignFieldName = null;
      this.combine = false;
    } else {
      this.foreignField = fieldList.get(foreign);
      this.foreignFieldName = fieldNameList.get(foreign);
      //			this.combine = this.foreign != this.primary;
      this.combine = false;
    }
    Preconditions.checkState(
        primary != -1,
        "Any DataEntity %s must contain @Primary Field",
        entityClass.getSimpleName());
    if (RefDataEntity.class.isAssignableFrom(entityClass)) {
      Preconditions.checkState(
          foreign != -1,
          "RefDataEntity %s must contain @Foreign Field",
          entityClass.getSimpleName());
      Preconditions.checkState(
          primary != foreign,
          "KeyDataEntity %s must sign @Primary&@Foreign to different Field",
          entityClass.getSimpleName());
    } else if (KeyDataEntity.class.isAssignableFrom(entityClass)) {
      Preconditions.checkState(
          foreign != -1,
          "KeyDataEntity %s must contain @Foreign Field",
          entityClass.getSimpleName());
      Preconditions.checkState(
          primary == foreign,
          "KeyDataEntity %s must sign @Primary&@Foreign to same Field",
          entityClass.getSimpleName());
    }
  }

  public K getPrimary(V v) {
    try {
      return (K) fields.get(primary).get(v);
    } catch (IllegalAccessException e) {
      throw new RuntimeException(e);
    }
  }

  public R getForeign(V v) {
    if (this.foreignField == null) {
      return null;
    }
    try {
      return (R) fields.get(foreign).get(v);
    } catch (IllegalAccessException e) {
      throw new RuntimeException(e);
    }
  }

  public V newInstance() throws IllegalAccessException, InstantiationException {
    return entityClass.newInstance();
  }

  public V newInstance(K id, R ref) throws IllegalAccessException, InstantiationException {
    V v = this.newInstance();
    fields.get(primary).set(v, id);
    if (foreign != -1) {
      fields.get(foreign).set(v, ref);
    }
    return v;
  }
}
