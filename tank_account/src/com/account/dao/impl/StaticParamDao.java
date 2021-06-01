package com.account.dao.impl;

import java.util.List;

import com.account.dao.BaseDao;
import com.account.domain.StaticParam;

public class StaticParamDao extends BaseDao {
    public List<StaticParam> selectStaticParams() {
        return this.getSqlSession().selectList("StaticParamDao.selectStaticParams");
    }
}
