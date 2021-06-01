package com.gamemysql.cache;

import com.gamemysql.core.entity.DataEntity;

public class Primary<K, R, V extends DataEntity<K, R>> {
  private final Class<V> type;
  private final K id;
  private final R ref;

  Primary(Class<V> type, K id, R ref) {
    this.type = type;
    this.id = id;
    this.ref = ref;
  }

  Class<V> getType() {
    return type;
  }

  K getId() {
    return id;
  }

  public R getRef() {
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

    Primary primary = (Primary) o;

    if (!type.equals(primary.type)) {
      return false;
    }
    if (!id.equals(primary.id)) {
      return false;
    }
    if (ref == null && primary.ref == null) {
      return true;
    } else if (ref == null || primary.ref == null) {
      return false;
    }

    if (ref != primary.ref && !ref.equals(primary.ref)) {
      return false;
    }

    return true;
  }

  @Override
  public int hashCode() {
    int result = type.hashCode();
    result = 31 * result + id.hashCode();
    if (ref != null) {
      result = 31 * result + ref.hashCode();
    }
    return result;
  }

  @Override
  public String toString() {
    return "Primary{" + "type=" + type + ", id=" + id + ", ref=" + ref + '}';
  }
}
