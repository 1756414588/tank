
package com.account.dao.impl;

import com.account.dao.BaseDao;
import com.account.domain.IpConfine;

public class IpConfineDao extends BaseDao {
    public IpConfine selectByIp(String ip) {
        return this.getSqlSession().selectOne("IpConfineDao.selectByIp", ip);
    }

    public void updateIpConfine(IpConfine ipConfine) {
        this.getSqlSession().update("IpConfineDao.updateIpConfine", ipConfine);
    }

    public void insertIpConfine(IpConfine ipConfine) {
        this.getSqlSession().insert("IpConfineDao.insertIpConfine", ipConfine);
    }
}
