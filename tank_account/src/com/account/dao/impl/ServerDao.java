package com.account.dao.impl;

import com.account.dao.BaseDao;
import com.account.domain.GameSaveErrorLog;
import com.account.domain.Server;

public class ServerDao extends BaseDao {
    public Server selectById(int serverId) {
        return this.getSqlSession().selectOne("ServerDao.selectById", serverId);
    }

    public Server selectByName(String name) {
        return this.getSqlSession().selectOne("ServerDao.selectByName", name);
    }

    public void updateServer(Server server) {
        this.getSqlSession().update("ServerDao.updateServer", server);
    }

    public void insertServer(Server server) {
        this.getSqlSession().insert("ServerDao.insertServer", server);
    }

    public void insertGameSaveErrorLog(GameSaveErrorLog log) {
        this.getSqlSession().insert("ServerDao.insertGameSaveErrorLog", log);
    }
}
