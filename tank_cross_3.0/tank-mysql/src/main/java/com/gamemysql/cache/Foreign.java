package com.gamemysql.cache;

import com.gamemysql.core.entity.DataEntity;

public class Foreign<K, R, V extends DataEntity<K, R>> {
  private final Class<V> type;
  private final R ref;

  public Foreign(Class<V> type, R ref) {
    this.type = type;
    this.ref = ref;
  }

  Class<V> getType() {
    return type;
  }

  R getRef() {
    return ref;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }

    Foreign key = (Foreign) o;

    if (!type.equals(key.type)) {
      return false;
    }
    if (ref == key.ref) {
      return true;
    }
    if (ref != key.ref && !ref.equals(key.ref)) {
      return false;
    }

    return true;
  }

  @Override
  public int hashCode() {
    int result = type.hashCode();
    if (ref != null) {
      result = 31 * result + ref.hashCode();
    }
    return result;
  }

  @Override
  public String toString() {
    return "Foreign{" + "type=" + type + ", ref=" + ref + '}';
  }
}
