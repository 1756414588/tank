package com.account.dao.impl;

import java.util.List;

import com.account.dao.BaseDao;

public class ForbidDeviceDao extends BaseDao {
    public List<String> selectForbidDevice() {
        return this.getSqlSession().selectList("ForbidDeviceDao.selectForbidDevice");
    }

    public void addForbidDevice(String deviceNo) {
        this.getSqlSession().insert("ForbidDeviceDao.addForbidDevice", deviceNo);
    }

}
