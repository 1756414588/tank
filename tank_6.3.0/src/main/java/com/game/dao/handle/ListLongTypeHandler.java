package com.game.dao.handle;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.TypeHandler;

import com.alibaba.fastjson.JSONArray;
/**
* @ClassName: ListLongTypeHandler 
* @Description: CHAR型字段[id,type,count]适配List<Long>
* @author
 */
public class ListLongTypeHandler implements TypeHandler<List<Long>> {
	private List<Long> getLongList(String columnValue) {
		List<Long> list = new ArrayList<Long>();
		if (columnValue == null || columnValue.isEmpty()) {
			return list;
		}

//		JSONArray array = JSONArray.fromObject(columnValue);
		JSONArray array = JSONArray.parseArray(columnValue);
		for (int i = 0; i < array.size(); i++) {
			long value = array.getLong(i);
			list.add(value);
		}
		return list;
	}

	private String listToString(List<Long> parameter) {
		JSONArray arrays = null;
		if (parameter == null || parameter.isEmpty()) {
			arrays = new JSONArray();
			return arrays.toString();
		}

//		arrays = JSONArray.fromObject(parameter);
		return JSONArray.toJSONString(parameter);
	}

	@Override
	public void setParameter(PreparedStatement arg0, int arg1, List<Long> arg2, JdbcType arg3) throws SQLException {
		//Auto-generated method stub
		arg0.setString(arg1, this.listToString(arg2));
	}

	@Override
	public List<Long> getResult(ResultSet rs, String columnName) throws SQLException {
		//Auto-generated method stub
		String columnValue = rs.getString(columnName);
		return this.getLongList(columnValue);
	}

	@Override
	public List<Long> getResult(ResultSet rs, int columnIndex) throws SQLException {
		return null;
	}

	@Override
	public List<Long> getResult(CallableStatement cs, int columnIndex) throws SQLException {
		//Auto-generated method stub
		return null;
	}

}
