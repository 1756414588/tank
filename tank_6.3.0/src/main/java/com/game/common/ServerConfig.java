package com.game.common;

import java.io.IOException;
import java.util.Properties;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

import com.game.util.LogUtil;

/**
 * @author
 * @ClassName: ServerConfig
 * @Description: 游戏服务器数据库连接配置    会从game.properties文件中获取参数值
 */
@Component
public class ServerConfig {

    @Value("${jdbcUrl}")
    private String jdbcUrl;

    @Value("${user}")
    private String user;

    @Value("${password}")
    private String password;

    @Value("${iniJdbcUrl}")
    private String iniJdbcUrl;

    @Value("${iniUser}")
    private String iniUser;

    @Value("${iniPassword}")
    private String iniPassword;

    @Value("${server.version}")
    private String serverVersion;

    public ServerConfig() {
    }

    public String getIniJdbcUrl() {
        return iniJdbcUrl;
    }

    public void setIniJdbcUrl(String iniJdbcUrl) {
        this.iniJdbcUrl = iniJdbcUrl;
    }

    public String getIniUser() {
        return iniUser;
    }

    public void setIniUser(String iniUser) {
        this.iniUser = iniUser;
    }

    public String getIniPassword() {
        return iniPassword;
    }

    public void setIniPassword(String iniPassword) {
        this.iniPassword = iniPassword;
    }

    @PostConstruct
    public void init() throws IOException {
        LogUtil.start("load server config begin!!!");
        String path = "game.properties";
        Resource resource = new FileSystemResource(path);
        if (resource.isReadable()) {
            Properties properties = new Properties();
            try {
                properties.load(resource.getInputStream());
                jdbcUrl = properties.getProperty("jdbcUrl");
                user = properties.getProperty("user");
                password = properties.getProperty("password");
                iniJdbcUrl = properties.getProperty("iniJdbcUrl");
                iniUser = properties.getProperty("iniUser");
                iniPassword = properties.getProperty("iniPassword");
                LogUtil.start("load server config success !!! current game server ");
            } catch (IOException e) {
                LogUtil.error("load server config exception", e);
                throw e;
            }
        } else {
            LogUtil.error("jdbc config resource can not read from out directory");
        }
    }

    public String getJdbcUrl() {
        return jdbcUrl;
    }

    public void setJdbcUrl(String jdbcUrl) {
        this.jdbcUrl = jdbcUrl;
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

    public void setPassword(String password) {
        this.password = password;
    }

    public String getServerVersion() {
        return serverVersion;
    }

    public void setServerVersion(String serverVersion) {
        this.serverVersion = serverVersion;
    }
}
