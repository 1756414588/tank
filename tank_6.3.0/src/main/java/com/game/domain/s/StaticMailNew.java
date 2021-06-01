package com.game.domain.s;

/**
 * @author yeding
 * @create 2019/4/10 11:38
 * @decs
 */
public class StaticMailNew {

    private int serverId;

    private int mailId;

    private String desc;

    public int getServerId() {
        return serverId;
    }

    public void setServerId(int serverId) {
        this.serverId = serverId;
    }

    public int getMailId() {
        return mailId;
    }

    public void setMailId(int mailId) {
        this.mailId = mailId;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    @Override
    public String toString() {
        return "StaticMailNew{" +
                "serverId=" + serverId +
                ", mailId=" + mailId +
                ", desc='" + desc + '\'' +
                '}';
    }
}
