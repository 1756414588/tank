package com.account.domain;

/**
 * 数据传输对象，角色信息
 *
 * @author TanDonghai
 */
public class Role {

    private String server_id;// 服务器id

    private String server_name;// 服务器名称

    private String role_id;// 角色id

    private String role_name;// 角色名

    private String level;// 等级

    private String vip;

    public String getServer_id() {
        return server_id;
    }

    public void setServer_id(String server_id) {
        this.server_id = server_id;
    }

    public String getServer_name() {
        return server_name;
    }

    public void setServer_name(String server_name) {
        this.server_name = server_name;
    }

    public String getRole_id() {
        return role_id;
    }

    public void setRole_id(String role_id) {
        this.role_id = role_id;
    }

    public String getRole_name() {
        return role_name;
    }

    public void setRole_name(String role_name) {
        this.role_name = role_name;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    @Override
    public String toString() {
        return "Role [server_id=" + server_id + ", server_name=" + server_name + ", role_id=" + role_id + ", role_name="
                + role_name + ", level=" + level + "]";
    }

    public String getVip() {
        return vip;
    }

    public void setVip(String vip) {
        this.vip = vip;
    }


}
