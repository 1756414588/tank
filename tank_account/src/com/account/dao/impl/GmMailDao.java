package com.account.dao.impl;

import java.util.List;

import com.account.dao.BaseDao;
import com.account.domain.GmMail;

public class GmMailDao extends BaseDao {
    public List<GmMail> selectGmMailList() {
        return this.getSqlSession().selectList("GmMailDao.getResult");
    }

    public List<GmMail> selectUnClose() {
        return this.getSqlSession().selectList("GmMailDao.selectUnClose");
    }

    public GmMail selectGMailAE(String ae) {
        return this.getSqlSession().selectOne("GmMailDao.selectGMailAE", ae);
    }

    public void createGmMail(GmMail gmMail) {
        this.getSqlSession().insert("GmMailDao.createGmMail", gmMail);
    }

    public void updateGmMail(GmMail gmMail) {
        this.getSqlSession().update("GmMailDao.updateGmMail", gmMail);
    }

}
