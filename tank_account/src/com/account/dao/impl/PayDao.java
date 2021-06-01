package com.account.dao.impl;

import java.util.HashMap;
import java.util.Map;

import com.account.dao.BaseDao;
import com.account.domain.Pay;

public class PayDao extends BaseDao {
    public Pay selectPay(int platNo, String orderId) {
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("platNo", platNo);
        map.put("orderId", orderId);
        return this.getSqlSession().selectOne("PayDao.selectPay", map);
    }

    public Pay selectRolePay(int serverId, long roleId) {
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("serverId", serverId);
        map.put("roleId", roleId);
        return this.getSqlSession().selectOne("PayDao.selectRolePay", map);
    }

//	public void updateState(Pay pay) {
//		this.getSqlSession().update("PayDao.updateState", pay);
//	}

    public void updateState(int platNo, String orderId, int state, int addGold) {
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("platNo", platNo);
        map.put("orderId", orderId);
        map.put("state", state);
        map.put("addGold", addGold);
        this.getSqlSession().update("PayDao.updateState", map);
    }

    public void createPay(Pay pay) {
        this.getSqlSession().insert("PayDao.createPay", pay);
    }
}
