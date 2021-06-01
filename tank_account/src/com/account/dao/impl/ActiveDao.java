package com.account.dao.impl;

import com.account.dao.BaseDao;
import com.account.domain.ActiveCode;

public class ActiveDao extends BaseDao {
    public ActiveCode selectActiveCode(long code) {
        return this.getSqlSession().selectOne("ActiveDao.selectActiveCode", code);
    }

    public void updateActiveCode(ActiveCode activeCode) {
        this.getSqlSession().update("ActiveDao.updateActiveCode", activeCode);
    }
}
