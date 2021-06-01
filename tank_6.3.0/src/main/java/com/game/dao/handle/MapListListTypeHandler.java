package com.game.dao.handle;

import com.alibaba.fastjson.JSONArray;
import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: MapListListTypeHandler
 * @Description: [[[key],[[],[]]],[[key],[[],[]]]] 格式解析
 * @date 2017-11-30 11:55
 */
public class MapListListTypeHandler extends BaseTypeHandler<Map<Integer, List<List<Integer>>>> {
    @Override
    public void setNonNullParameter(PreparedStatement preparedStatement, int i, Map<Integer, List<List<Integer>>> integerListMap, JdbcType jdbcType) throws SQLException {

    }

    @Override
    public Map<Integer, List<List<Integer>>> getNullableResult(ResultSet rs, String columnName) throws SQLException {
        String columnValue = rs.getString(columnName);
        return this.parser(columnValue);
    }

    @Override
    public Map<Integer, List<List<Integer>>> getNullableResult(ResultSet resultSet, int i) throws SQLException {
        return null;
    }

    @Override
    public Map<Integer, List<List<Integer>>> getNullableResult(CallableStatement callableStatement, int i) throws SQLException {
        return null;
    }

    /**
     * [[[key],[[],[]]],[[key],[[],[]]]]
     * @param columnValue
     * @return
     */
    private Map<Integer, List<List<Integer>>> parser(String columnValue) {
        Map<Integer, List<List<Integer>>> mapList = new HashMap<>();
        if (columnValue == null || columnValue.isEmpty()) {
            return mapList;
        }
        JSONArray arrays = JSONArray.parseArray(columnValue);
        for (int i = 0; i < arrays.size(); i++) {
            JSONArray array = arrays.getJSONArray(i);
            Integer key = array.getJSONArray(0).getInteger(0);
            JSONArray valArr = array.getJSONArray(1);
            List<List<Integer>> retList = new ArrayList<>();
            for (int j = 0; j < valArr.size(); j++) {
                List<Integer> list = new ArrayList<>();
                JSONArray arrayj = valArr.getJSONArray(j);
                for (int k = 0; k < arrayj.size(); k++) {
                    list.add(arrayj.getInteger(k));
                }
                retList.add(list);
            }
            mapList.put(key, retList);
        }
        return mapList;
    }
}
