package com.account.dao.impl;

import java.util.Map;

import com.account.dao.BaseDao;
import com.account.domain.ActionPoint;

public class ActionPointDao extends BaseDao {
    public ActionPoint selectActionPoint(String deviceNo) {
        Map<String, Object> param = this.paramsMap();
        param.put("deviceNo", deviceNo);
        return this.getSqlSession().selectOne("ActionPointDao.selectActionPoint", param);
    }

    public void insertActionPoint(ActionPoint actionPoint) {
        this.getSqlSession().insert("ActionPointDao.insertActionPointDao", actionPoint);
    }

    public void updateActionPoint(ActionPoint actionPoint) {
        this.getSqlSession().insert("ActionPointDao.updateActionPointDao", actionPoint);
    }

}
