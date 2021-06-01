package com.game.dao.handle;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;

import com.alibaba.fastjson.JSONArray;

/**
 * @author 
 * @ClassName: TreeMapListType2Handler
 * @Description: [[key,[]],[key,[]]] 格式解析为Map<Integer, List<Integer>>
 */
public class TreeMapListType2Handler extends BaseTypeHandler<Map<Integer, List<Integer>>> {

	@Override
	public void setNonNullParameter(PreparedStatement ps, int i, Map<Integer, List<Integer>> parameter, JdbcType jdbcType) throws SQLException {
		//Auto-generated method stub

	}

	@Override
	public Map<Integer, List<Integer>> getNullableResult(ResultSet rs, String columnName) throws SQLException {
		//Auto-generated method stub
		String columnValue = rs.getString(columnName);
		return this.getMapList(columnValue);
	}

	@Override
	public Map<Integer, List<Integer>> getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
		//Auto-generated method stub
		return null;
	}

	@Override
	public Map<Integer, List<Integer>> getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
		//Auto-generated method stub
		return null;
	}

	private TreeMap<Integer, List<Integer>> getMapList(String columnValue) {
        TreeMap<Integer, List<Integer>> mapList = new TreeMap<>();
		if (columnValue == null || columnValue.isEmpty()) {
			return mapList;
		}
		
		JSONArray arrays = JSONArray.parseArray(columnValue);
		for (int i = 0; i < arrays.size(); i++) {
			JSONArray array = arrays.getJSONArray(i);
			Integer key = array.getJSONArray(0).getInteger(0);
			JSONArray valArr = array.getJSONArray(1);
			
			List<Integer> list = new ArrayList<Integer>();
			for (int j = 0; j < valArr.size(); j++) {
				list.add(valArr.getIntValue(j));
			}
			mapList.put(key, list);
		}

		return mapList;
	}

}
