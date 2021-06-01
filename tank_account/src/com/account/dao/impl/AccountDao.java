
package com.account.dao.impl;

import java.util.List;
import java.util.Map;

import com.account.dao.BaseDao;
import com.account.domain.Account;

public class AccountDao extends BaseDao {
    public Account selectByAccount(String account, int platNo) {
        Map<String, Object> param = this.paramsMap();
        param.put("account", account);
        param.put("platNo", String.valueOf(platNo));
        return this.getSqlSession().selectOne("AccountDao.selectByAccount", param);
    }

    public List<Account> selectByAccount(String platId, List<Integer> platNoList) {
        Map<String, Object> param = this.paramsMap();
        param.put("platNoList", platNoList);
        param.put("platId", platId);
        return this.getSqlSession().selectList("AccountDao.selectByPlatIdUserId", param);
    }

    public Account selectByKey(int keyId) {
        return this.getSqlSession().selectOne("AccountDao.selectByKey", keyId);
    }

    public Account selectByPlatId(int platNo, String platId) {
        Map<String, Object> param = this.paramsMap();
        param.put("platNo", platNo);
        param.put("platId", platId);
        return this.getSqlSession().selectOne("AccountDao.selectByPlatId", param);
    }

    public List<Account> selectByDeviceNo(String deviceNo, int platNo) {
        Map<String, Object> param = this.paramsMap();
        param.put("deviceNo", deviceNo);
        param.put("platNo", String.valueOf(platNo));
        return this.getSqlSession().selectList("AccountDao.selectByDeviceNo", param);
    }

    public void updateRecentServer(Account account) {
        this.getSqlSession().update("AccountDao.updateRecentServer", account);
    }

    public void updateForbid(Account account) {
        this.getSqlSession().update("AccountDao.updateForbid", account);
    }

    public void updateActive(Account account) {
        this.getSqlSession().update("AccountDao.updateActive", account);
    }

    public void updatePwd(Account account) {
        this.getSqlSession().update("AccountDao.updatePwd", account);
    }

    public void updateTokenAndVersion(Account account) {
        this.getSqlSession().update("AccountDao.updateTokenAndVersion", account);
    }

    public void updateVersionNo(Account account) {
        this.getSqlSession().update("AccountDao.updateVersionNo", account);
    }

    public void updateChildNo(Account account) {
        this.getSqlSession().update("AccountDao.updateChildNo", account);
    }

    public void insertWithPlat(Account account) {
        this.getSqlSession().insert("AccountDao.insertWithPlat", account);
    }

    public void insertWithAccount(Account account) {
        this.getSqlSession().insert("AccountDao.insertWithAccount", account);
    }
}
