package com.account.dao.impl;

import com.account.dao.BaseDao;

import java.util.List;
import java.util.Map;

public class RolePointDao extends BaseDao {

    public void insert(String sql) {
        Map<String, Object> param = this.paramsMap();
        param.put("sql", sql);
        this.getSqlSession().insert("RolePointDao.insertActionPoint", param);

    }

    public List<String> showTables() {
        return this.getSqlSession().selectList("RolePointDao.showTables");
    }

    public void createTable(String sql) {
        Map<String, Object> param = this.paramsMap();
        param.put("sql", sql);
        this.getSqlSession().update("RolePointDao.createTable", param);
    }

}
