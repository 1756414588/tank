package com.account.service;

import java.util.Date;

import org.springframework.beans.factory.annotation.Autowired;

import com.account.constant.GameError;
import com.account.dao.impl.ServerDao;
import com.account.domain.GameSaveErrorLog;
import com.account.domain.Server;
import com.game.pb.InnerPb.RegisterRq;
import com.game.pb.InnerPb.RegisterRs;
import com.game.pb.InnerPb.ServerErrorLogRq;

import net.sf.json.JSONObject;

public class ManageService {
    @Autowired
    private ServerDao serverDao;

    public GameError registerServer(JSONObject param) {
        String serverName = param.getString("serverName");
        Server server = serverDao.selectByName(serverName);
        if (server == null) {
            server = new Server();
            server.setServerName(serverName);
            server.setCreateTime(new Date());
            registerData(param, server);
            serverDao.insertServer(server);
        } else {
            server.setLastStartTime(server.getStartTime());
            registerData(param, server);
            serverDao.updateServer(server);
        }

        return GameError.OK;
    }

    private void registerData(JSONObject param, Server server) {
        server.setIp(param.getString("ip"));
        server.setPort(param.getInt("port"));
        server.setServerType(param.getInt("serverType"));
        Date startTime = new Date();
        startTime.setTime(param.getLong("startTime"));
        server.setStartTime(startTime);
        server.setState(param.getInt("state"));
        server.setDbName(param.getString("dbName"));
        server.setUserName(param.getString("userName"));
        server.setUserPwd(param.getString("userPwd"));
    }

    public GameError registerServer(RegisterRq req, RegisterRs.Builder builder) {
        int serverId = req.getServerId();
        String serverName = req.getServerName();
        builder.setState(1);
        System.out.printf("服务器 [%d区]" + "[%s]" + "注册到account!", serverId, serverName);
        return GameError.OK;
    }

    public GameError sererErrorLog(ServerErrorLogRq req) {
        GameSaveErrorLog log = new GameSaveErrorLog();
        log.setServerId(req.getServerId());
        log.setDataType(req.getDataType());
        log.setErrorCount(req.getErrorCount());
        log.setErrorDesc(req.getErrorDesc());
        log.setErrorTime(new Date(req.getErrorTime()));
        log.setLogTime(new Date());

        try {
            serverDao.insertGameSaveErrorLog(log);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return GameError.OK;
    }
}
