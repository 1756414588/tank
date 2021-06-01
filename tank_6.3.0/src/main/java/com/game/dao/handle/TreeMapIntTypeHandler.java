package com.game.dao.handle;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;
import java.util.TreeMap;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;

import com.alibaba.fastjson.JSONArray;
/**
* @ClassName: TreeMapIntTypeHandler 
* @Description: [[key,int],[key,int],[key,int]]适配ListMap<Integer, Integer>
* @author
 */
public class TreeMapIntTypeHandler extends BaseTypeHandler<Map<Integer, Integer>> {

	@Override
	public void setNonNullParameter(PreparedStatement ps, int i, Map<Integer, Integer> parameter, JdbcType jdbcType) throws SQLException {
		//Auto-generated method stub
		ps.setString(i, this.mapToString(parameter));
	}

	@Override
	public Map<Integer, Integer> getNullableResult(ResultSet rs, String columnName) throws SQLException {
		//Auto-generated method stub
		String columnValue = rs.getString(columnName);
		return this.getMap(columnValue);
	}

	@Override
	public Map<Integer, Integer> getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
		//Auto-generated method stub
		return null;
	}

	@Override
	public Map<Integer, Integer> getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
		//Auto-generated method stub
		return null;
	}

	private String mapToString(Map<Integer, Integer> parameter) {
		JSONArray arrays = new JSONArray();
		if (parameter == null || parameter.isEmpty()) {
			return arrays.toJSONString();
		}

		for (Map.Entry<Integer, Integer> entry : parameter.entrySet()) {
			JSONArray array = new JSONArray();
			array.add(entry.getKey());
			array.add(entry.getValue());
			arrays.add(array);
		}

		return arrays.toJSONString();
	}

	private TreeMap<Integer, Integer> getMap(String columnValue) {
		TreeMap<Integer, Integer> map = new TreeMap<>();
		if (columnValue == null) {
			return map;
		}
		
		if (columnValue.startsWith("[[")) {
			JSONArray arrays = JSONArray.parseArray(columnValue);
			for (int i = 0; i < arrays.size(); i++) {
				JSONArray array = arrays.getJSONArray(i);
				int key = array.getIntValue(0);
				int value = array.getIntValue(1);
				map.put(key, value);
			}
		}

		else if (columnValue.startsWith("[")) {
			JSONArray array = JSONArray.parseArray(columnValue);
			map.put(array.getInteger(0), array.getInteger(1));
		}

		return map;
	}
}


