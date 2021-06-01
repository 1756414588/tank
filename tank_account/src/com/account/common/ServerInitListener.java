package com.account.common;

import java.util.Date;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.context.event.ContextStartedEvent;
import org.springframework.context.event.ContextStoppedEvent;

import com.account.dao.impl.ServerDao;
import com.account.domain.Server;
import com.account.util.IpHelper;
import com.account.util.PrintHelper;

@SuppressWarnings("rawtypes")
public class ServerInitListener implements ApplicationListener {
    @Autowired
    private ServerSetting serverSetting;

    @Autowired
    private ServerConfig serverConfig;

    @Autowired
    private ServerDao serverDao;

    @Override
    public void onApplicationEvent(ApplicationEvent event) {
        // TODO Auto-generated method stub
        if (event instanceof ContextStartedEvent) {
            onStart();
        } else if (event instanceof ContextRefreshedEvent) {
            onRefresh();
        } else if (event instanceof ContextStoppedEvent) {
            onStop();
        } else if (event instanceof ContextClosedEvent) {
            onClose();
        }
    }

    private Server getServerDo(Server server) {
        String ip = IpHelper.getWireIp();
        if (ip == null) {
            ip = IpHelper.getLocalIp();
        }

        server.setServerName(serverConfig.getAppId());
        server.setIp(ip);
        server.setPort(IpHelper.getHttpPort());
        server.setDbName(serverConfig.getJdbcUrl());
        server.setUserName(serverConfig.getUser());
        server.setUserPwd(serverConfig.getPassword());
        server.setStartTime(new Date());
        if (serverSetting.isOpenWhiteName()) {
            server.setState(1);
        } else {
            server.setState(0);
        }
        server.setServerType(1);
        return server;
    }

    /**
     * gets initialized or refreshed
     */
    private void onRefresh() {
        //PrintHelper.println("account ServerInitListener onRefresh");
        Server server = serverDao.selectByName(serverConfig.getAppId());
        if (server == null) {
            server = new Server();
            getServerDo(server);
            server.setCreateTime(new Date());
            serverDao.insertServer(server);
        } else {
            server.setLastStartTime(server.getStartTime());
            getServerDo(server);
            serverDao.updateServer(server);
        }
    }

    /**
     *
     */
    private void onStart() {
        PrintHelper.println("account ServerInitListener onStart");
    }

    /**
     * 会销毁所有单例bean
     */
    private void onClose() {
        PrintHelper.println("account ServerInitListener onClose");
    }

    /**
     *
     */
    private void onStop() {
        PrintHelper.println("account ServerInitListener onStop");
    }
}
