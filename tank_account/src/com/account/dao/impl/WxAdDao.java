package com.account.dao.impl;

import java.util.Map;

import com.account.dao.BaseDao;
import com.account.domain.WxAdvertise;

public class WxAdDao extends BaseDao {
    public WxAdvertise selectWxAdvertise(int platNo, String muid) {
        Map<String, Object> param = this.paramsMap();
        param.put("platNo", platNo);
        param.put("muid", muid);
        return this.getSqlSession().selectOne("WxAdDao.selectWxAdvertise", param);
    }

    public void insertWxAdvertise(WxAdvertise advertise) {
        this.getSqlSession().insert("WxAdDao.insertWxAdvertise", advertise);
    }

    public void updateWxAdvertise(WxAdvertise advertise) {
        this.getSqlSession().update("WxAdDao.updateWxAdvertise", advertise);
    }
}
