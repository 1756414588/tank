package com.account.dao.impl;

import com.account.dao.BaseDao;
import com.account.domain.form.RoleLog;

import java.util.List;
import java.util.Map;

public class RoleInfoDao extends BaseDao {

    public List<String> showTables() {
        return this.getSqlSession().selectList("RoleInfoDao.showTables");
    }

    public void createTable(String sql) {
        Map<String, Object> param = this.paramsMap();
        param.put("sql", sql);
        this.getSqlSession().update("RoleInfoDao.createTable", param);
    }

    public List<RoleLog> queryRoleLog(int platNo, int platId) {
        Map<String, Object> param = this.paramsMap();
        param.put("platNo", platNo);
        param.put("platId", platId);
        return this.getSqlSession().selectList("RoleInfoDao.selectByPlatId", param);
    }

    public RoleLog queryRoleByLordId(long lordId) {
        return this.getSqlSession().selectOne("RoleInfoDao.selectByLordId", lordId);
    }

    public void insertRoleLog(RoleLog role) {
        this.getSqlSession().insert("RoleInfoDao.insert", role);
    }

}
