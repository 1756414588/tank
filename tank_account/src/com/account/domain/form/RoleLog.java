package com.account.domain.form;

/**
 * 数据传输对象，角色信息
 *
 * @author TanDonghai
 */
public class RoleLog {

    private int accountKey;// sdk给的账号key

    private String serverId;// 服务器id

    private String serverName;// 服务器名称

    private long roleId;// 角色id

    private String roleName;// 角色名

    private String level;// 等级

    private String subject;// 什么操作时触发日志

    private long createTime;// 角色创建时间

    private String platId;// 渠道id

    private int platNo;

    private int childNo;

    private int vip;

    private int topop;

    private long loginDate;

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public long getCreateTime() {
        return createTime;
    }

    public void setCreateTime(long createTime) {
        this.createTime = createTime;
    }

    public String getServerId() {
        return serverId;
    }

    public void setServerId(String serverId) {
        this.serverId = serverId;
    }

    public String getServerName() {
        return serverName;
    }

    public void setServerName(String serverName) {
        this.serverName = serverName;
    }

    public long getRoleId() {
        return roleId;
    }

    public void setRoleId(long roleId) {
        this.roleId = roleId;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public String getPlatId() {
        return platId;
    }

    public void setPlatId(String platId) {
        this.platId = platId;
    }

    public int getPlatNo() {
        return platNo;
    }

    public void setPlatNo(int platNo) {
        this.platNo = platNo;
    }

    public int getChildNo() {
        return childNo;
    }

    public void setChildNo(int childNo) {
        this.childNo = childNo;
    }

    public int getVip() {
        return vip;
    }

    public void setVip(int vip) {
        this.vip = vip;
    }

    public int getTopop() {
        return topop;
    }

    public void setTopop(int topop) {
        this.topop = topop;
    }

    public long getLoginDate() {
        return loginDate;
    }

    public void setLoginDate(long loginDate) {
        this.loginDate = loginDate;
    }

    @Override
    public String toString() {
        return "RoleLog{" + "accountKey=" + accountKey + ", serverId='" + serverId + '\'' + ", serverName='" + serverName + '\'' + ", roleId='" + roleId + '\'' + ", roleName='" + roleName + '\'' + ", level='" + level + '\'' + ", subject='" + subject + '\'' + ", createTime=" + createTime + ", platId='" + platId + '\'' + ", platNo=" + platNo + ", childNo=" + childNo + ", vip=" + vip + ", topop=" + topop + ", loginDate=" + loginDate + '}';
    }

    public int getAccountKey() {
        return accountKey;
    }

    public void setAccountKey(int accountKey) {
        this.accountKey = accountKey;
    }

}
