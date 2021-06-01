package com.gamemysql.jdbc;

import java.sql.ResultSet;

/** @param <T> */
public interface RowMapper<T> {
  T mapRow(ResultSet rs, int rowNum) throws Exception;
}
