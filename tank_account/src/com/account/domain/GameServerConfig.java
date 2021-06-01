package com.account.domain;

/**
 * @Author :GuiJie Liu
 * @date :Create in 2019/3/28 17:15
 * @Description :游戏服务器和数据库信息配置表
 */
public class GameServerConfig {
    /**
     * 地区
     */
    private String region;
    /**
     * 客户端系统、平台
     */
    private String os;
    /**
     * 服务器id
     */
    private int serverId;
    /**
     * 服务器名称
     */
    private String serverName;
    /**
     * 服务器内网ip
     */
    private String serverIp;
    /**
     * 游戏数据库登录用户名
     */
    private String userName;
    /**
     * 数据库登录密码
     */
    private String password;
    /**
     * 游戏数据库名
     */
    private String dbName;
    /**
     * 游戏数据库ip
     */
    private String gameDbIp;

    public String getRegion() {
        return region;
    }

    public void setRegion(String region) {
        this.region = region;
    }

    public String getOs() {
        return os;
    }

    public void setOs(String os) {
        this.os = os;
    }

    public int getServerId() {
        return serverId;
    }

    public void setServerId(int serverId) {
        this.serverId = serverId;
    }

    public String getServerName() {
        return serverName;
    }

    public void setServerName(String serverName) {
        this.serverName = serverName;
    }

    public String getServerIp() {
        return serverIp;
    }

    public void setServerIp(String serverIp) {
        this.serverIp = serverIp;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getDbName() {
        return dbName;
    }

    public void setDbName(String dbName) {
        this.dbName = dbName;
    }

    public String getGameDbIp() {
        return gameDbIp;
    }

    public void setGameDbIp(String gameDbIp) {
        this.gameDbIp = gameDbIp;
    }

    @Override
    public String toString() {
        return "GameServerConfig{" +
                "region='" + region + '\'' +
                ", os='" + os + '\'' +
                ", serverId=" + serverId +
                ", serverName='" + serverName + '\'' +
                ", serverIp='" + serverIp + '\'' +
                ", userName='" + userName + '\'' +
                ", password='" + password + '\'' +
                ", dbName='" + dbName + '\'' +
                ", gameDbIp='" + gameDbIp + '\'' +
                '}';
    }
}
