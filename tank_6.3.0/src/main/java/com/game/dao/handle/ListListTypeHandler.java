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
import com.game.util.LogUtil;

/**
* @ClassName: ListListTypeHandler 
* @Description: CHAR型字段[[id,type,count], [id,type,count]...]适配List<List<Integer>>
* @author
 */
public class ListListTypeHandler implements TypeHandler<List<List<Integer>>> {
    private String listToString(List<List<Integer>> parameter) {
        JSONArray arrays = null;
        if (parameter == null || parameter.isEmpty()) {
            arrays = new JSONArray();
            return arrays.toString();
        }

        // arrays = JSONArray.fromObject(parameter);
        return JSONArray.toJSONString(parameter);
    }

    private List<List<Integer>> getListList(String columnName, String columnValue) {
        List<List<Integer>> listList = new ArrayList<List<Integer>>();
        if (columnValue == null || columnValue.isEmpty()) {
            return listList;
        }

        // JSONArray arrays = JSONArray.fromObject(columnValue);
        try {
            JSONArray arrays = JSONArray.parseArray(columnValue);
            for (int i = 0; i < arrays.size(); i++) {
                List<Integer> list = new ArrayList<Integer>();
                JSONArray array = arrays.getJSONArray(i);
                for (int j = 0; j < array.size(); j++) {
                    list.add(array.getInteger(j));
                }

                // if (!list.isEmpty()) {
                listList.add(list);
                // }
            }
        } catch (Exception e) {
            LogUtil.error(String.format("column name :%s, column value :%s parser error ", columnName, columnValue));
            throw e;
        }

        return listList;
    }

    @Override
    public void setParameter(PreparedStatement ps, int i, List<List<Integer>> parameter, JdbcType jdbcType) throws SQLException {
        //Auto-generated method stub
        ps.setString(i, this.listToString(parameter));
    }

    @Override
    public List<List<Integer>> getResult(ResultSet rs, String columnName) throws SQLException {
        //Auto-generated method stub
        String columnValue = rs.getString(columnName);
        return this.getListList(columnName, columnValue);
    }

    @Override
    public List<List<Integer>> getResult(ResultSet rs, int columnIndex) throws SQLException {
        //Auto-generated method stub
        return null;
    }

    @Override
    public List<List<Integer>> getResult(CallableStatement cs, int columnIndex) throws SQLException {
        //Auto-generated method stub
        return null;
    }
}
