package com.account.dao.impl;

import java.util.Map;

import com.account.dao.BaseDao;
import com.account.domain.Advertise;
import com.account.domain.ZhtAdvertise;

public class AdvertiseDao extends BaseDao {

    public Advertise selectAdvertiseByIdfa(int platNo, String idfa) {
        Map<String, Object> param = this.paramsMap();
        param.put("platNo", platNo);
        param.put("idfa", idfa);
        return this.getSqlSession().selectOne("AdvertiseDao.selectAdvertiseByIdfa", param);
    }

    public void insertAdvertise(Advertise advertise) {
        this.getSqlSession().insert("AdvertiseDao.insertAdvertise", advertise);
    }

    public void updateAdvertise(Advertise advertise) {
        this.getSqlSession().update("AdvertiseDao.updateAdvertise", advertise);
    }


    public ZhtAdvertise selectZhtAdvertiseByIdfa(int platNo, String muid) {
        Map<String, Object> param = this.paramsMap();
        param.put("platNo", platNo);
        param.put("muid", muid);
        return this.getSqlSession().selectOne("AdvertiseDao.selectZhtAdvertiseByIdfa", param);
    }

    public void insertZhtAdvertise(ZhtAdvertise advertise) {
        this.getSqlSession().insert("AdvertiseDao.insertZhtAdvertise", advertise);
    }

    public void updateZhtAdvertise(ZhtAdvertise advertise) {
        this.getSqlSession().update("AdvertiseDao.updateZhtAdvertise", advertise);
    }
}
