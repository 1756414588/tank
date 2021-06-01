package com.account.dao.impl;

import com.account.dao.BaseDao;
import com.account.domain.RoleData;

public class RoleDao extends BaseDao {

    public RoleData selectRoleDataByAccountKey(int accountKey) {
        return this.getSqlSession().selectOne("RoleDao.selectRoleDataByAccountKey", accountKey);
    }

    public void insertRoleData(RoleData rd) {
        this.getSqlSession().insert("RoleDao.insertRoleData", rd);
    }

    public void updateRoleData(RoleData rd) {
        this.getSqlSession().update("RoleDao.updateRoleData", rd);
    }
}
