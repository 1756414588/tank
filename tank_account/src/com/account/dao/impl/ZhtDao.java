package com.account.dao.impl;

import java.util.Map;

import com.account.dao.BaseDao;
import com.account.domain.ZhtAdvertise;
import com.account.domain.ZhtIdfa;

public class ZhtDao extends BaseDao {
    public ZhtAdvertise selectZhtAdvertise(int platNo, String muid) {
        Map<String, Object> param = this.paramsMap();
        param.put("platNo", platNo);
        param.put("muid", muid);
        return this.getSqlSession().selectOne("ZhtDao.selectZhtAdvertise", param);
    }

    public void insertZhtAdvertise(ZhtAdvertise advertise) {
        this.getSqlSession().insert("ZhtDao.insertZhtAdvertise", advertise);
    }

    public void updateZhtAdvertise(ZhtAdvertise advertise) {
        this.getSqlSession().update("ZhtDao.updateZhtAdvertise", advertise);
    }

    public ZhtIdfa selectZhtIdfa(int platNo, String muid) {
        Map<String, Object> param = this.paramsMap();
        param.put("platNo", platNo);
        param.put("muid", muid);
        return this.getSqlSession().selectOne("ZhtDao.selectZhtIdfa", param);
    }

    public void insertZhtIdfa(ZhtIdfa zhtIdfa) {
        this.getSqlSession().insert("ZhtDao.insertZhtIdfa", zhtIdfa);
    }
}
