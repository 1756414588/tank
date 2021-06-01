package com.account.common;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import javax.annotation.PostConstruct;

import com.account.controller.MessageController;
import com.account.dao.impl.RoleInfoDao;
import com.account.manager.ServerListManager;
import com.account.util.ServerListHelper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

import com.account.util.PrintHelper;

/**
* @Author :GuiJie Liu
* @date :Create in 2019/3/28 17:07
* @Description :java类作用描述
*/
@Component
public class ServerConfig {

    public static Logger LOG = LoggerFactory.getLogger(ServerConfig.class);
    /**
     * tank_account 用于读取war包外的 jdbc信息
     */
    private String appId;

    @Value("${jdbcUrl}")
    private String jdbcUrl;

    @Value("${user}")
    private String user;

    @Value("${password}")
    private String password;

    @Value("${jdbcPath}")
    private String jdbcPath;

    @Autowired
    private ServerListManager serverListManager;

    /**
     * 后台日志库的 数据库连接用于查询游戏数据库的 数据库连接信息
     */
    private String gameJdbcUrl;

    /**
     * 后台日志库的 数据库账号用于查询游戏数据库的 数据库连接信息
     */
    private String gameUser;
    /**
     * 后台日志库的 数据库密码用于查询游戏数据库的 数据库连接信息
     */
    private String gamePassword;
    /**
     * 后台日志库的 game_server_cfg 数据库连接用于查询游戏数据库的 数据库连接信息
     */
    private String gameTable;

    /**
     * 获取所有的 serverList 信息,客户端也使用的这个  有服务器ip 端口
     */
    private String serverListUrl;

    /**
     * 如果远程拉取 serverList信息失败,就启用系统路径读取
     */
    private String serverListFile;

    /**
     * 是一个php的后台连接 用于查询游戏数据库连接信息 主要用于 tank-account-role
     */
    private String gameServerInfo;

    public ServerConfig() {
    }

    @PostConstruct
    public void init() {
        setAppId("tank_account");
        PrintHelper.println("server unique name:" + appId);
        String path = jdbcPath + "/" + appId + ".properties";

        LOG.info("jdbc properties 地址{} ", path);

        Resource resource = new FileSystemResource(path);
        InputStream is = null;
        if (resource.isReadable()) {
            Properties properties = new Properties();
            try {
                is = resource.getInputStream();
                properties.load(is);
                jdbcUrl = properties.getProperty("jdbcUrl");
                user = properties.getProperty("user");
                password = properties.getProperty("password");
                gameJdbcUrl = properties.getProperty("gameJdbcUrl");
                gameUser = properties.getProperty("gameUser");
                gamePassword = properties.getProperty("gamePassword");
                gameTable = properties.getProperty("gameTable");
                serverListUrl = properties.getProperty("serverListUrl");
                serverListFile = properties.getProperty("serverListFile");
                gameServerInfo = properties.getProperty("gameServerInfo");
                if (is != null) {
                    is.close();
                }
            } catch (IOException e) {
                LOG.error("",e);
            }
        } else {
            LOG.info("没有配置地址 /var/ftp/server/tank_config/tank_account.properties ");
        }
        ServerListHelper.setServerConfig(this);

        if( getServerListUrl() != null || getServerListFile() != null ){
            serverListManager.initServerList();
        }

        LOG.info("ServerConfig info {}", this.toString());
    }

    public String getJdbcUrl() {
        return jdbcUrl;
    }

    public String getUser() {
        return user;
    }

    public void setUser(String user) {
        this.user = user;
    }

    public String getPassword() {
        return password;
    }

    public String getAppId() {
        return appId;
    }

    public void setAppId(String appId) {
        this.appId = appId;
    }

    public String getJdbcPath() {
        return jdbcPath;
    }

    public String getGameJdbcUrl() {
        return gameJdbcUrl;
    }

    public String getGameUser() {
        return gameUser;
    }

    public String getGamePassword() {
        return gamePassword;
    }


    public String getGameTable() {
        return gameTable;
    }


    public String getServerListUrl() {
        return serverListUrl;
    }


    public String getServerListFile() {
        return serverListFile;
    }


    public String getGameServerInfo() {
        return gameServerInfo;
    }

    @Override
    public String toString() {
        return "ServerConfig{" +
                "appId='" + appId + '\'' +
                ", jdbcUrl='" + jdbcUrl + '\'' +
                ", user='" + user + '\'' +
                ", password='" + password + '\'' +
                ", jdbcPath='" + jdbcPath + '\'' +
                ", gameJdbcUrl='" + gameJdbcUrl + '\'' +
                ", gameUser='" + gameUser + '\'' +
                ", gamePassword='" + gamePassword + '\'' +
                ", gameTable='" + gameTable + '\'' +
                ", serverListUrl='" + serverListUrl + '\'' +
                ", serverListFile='" + serverListFile + '\'' +
                ", gameServerInfo='" + gameServerInfo + '\'' +
                '}';
    }
}
