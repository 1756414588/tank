package com.game.dao.handle;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.TypeHandler;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
/**
* @ClassName: ArrayIntIntTypeHandler 
* @Description: CHAR型字段[[id,type,count], [id,type,count]...]适配Integer[][]
* @author
 */
public class ArrayIntIntTypeHandler implements TypeHandler<Integer[][]> {


    private Integer[][] getIntegerArray(String columnValue) {
      
        if (columnValue == null || columnValue.isEmpty()) {
            return new Integer[0][0];
        }
        JSONArray array = JSONArray.parseArray(columnValue);
        Integer[][] arrayInt = new Integer[array.size()][];
        for (int i = 0; i < arrayInt.length; i++) {
            JSONArray sonarray = array.getJSONArray(i);
            arrayInt[i] = new Integer[sonarray.size()];
            for (int j = 0; j <  arrayInt[i] .length; j++) {
                arrayInt[i][j] = sonarray.getInteger(j);
            }
        }
        return  arrayInt;
    }

    private String arrayToString(Integer[][] parameter) {
        JSONArray arrays = null;
        if (parameter == null || parameter.length==0) {
            arrays = new JSONArray();
            return arrays.toJSONString();
        }

        return JSON.toJSONString(parameter);
    }

	@Override
	public void setParameter(PreparedStatement ps, int i, Integer[][] parameter, JdbcType jdbcType) throws SQLException {
		//Auto-generated method stub
		ps.setString(i, this.arrayToString(parameter));
	}

	@Override
	public Integer[][] getResult(ResultSet rs, String columnName) throws SQLException {
		//Auto-generated method stub
		String columnValue = rs.getString(columnName);
		return this.getIntegerArray(columnValue);
	}

	@Override
	public Integer[][] getResult(ResultSet rs, int columnIndex) throws SQLException {
		return null;
	}

	@Override
	public Integer[][] getResult(CallableStatement cs, int columnIndex) throws SQLException {
		//Auto-generated method stub
		return null;
	}
}
