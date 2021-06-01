package com.game.dao.handle;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.TypeHandler;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ListIntTypeHandler implements TypeHandler<List<Integer>> {
  private List<Integer> getIntegerList(String columnValue) {
    List<Integer> list = new ArrayList<Integer>();
    if (columnValue == null || columnValue.isEmpty()) {
      return list;
    }

    JSONArray array = JSONArray.parseArray(columnValue);
    for (int i = 0; i < array.size(); i++) {
      int value = array.getIntValue(i);
      list.add(value);
    }
    return list;
  }

  private String listToString(List<Integer> parameter) {
    JSONArray arrays = null;
    if (parameter == null || parameter.isEmpty()) {
      arrays = new JSONArray();
      return arrays.toJSONString();
    }

    return JSON.toJSONString(parameter);
  }

  @Override
  public void setParameter(PreparedStatement ps, int i, List<Integer> parameter, JdbcType jdbcType)
      throws SQLException {
    // TODO Auto-generated method stub
    ps.setString(i, this.listToString(parameter));
  }

  @Override
  public List<Integer> getResult(ResultSet rs, String columnName) throws SQLException {
    // TODO Auto-generated method stub
    String columnValue = rs.getString(columnName);
    return this.getIntegerList(columnValue);
  }

  @Override
  public List<Integer> getResult(ResultSet rs, int columnIndex) throws SQLException {
    return null;
  }

  @Override
  public List<Integer> getResult(CallableStatement cs, int columnIndex) throws SQLException {
    // TODO Auto-generated method stub
    return null;
  }
}
