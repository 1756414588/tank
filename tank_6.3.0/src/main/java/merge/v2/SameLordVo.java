package merge.v2;

import merge.MServer;

import java.util.List;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/5/27 18:18
 * @description：
 */
public class SameLordVo {

    private long roleId;


    private List<SameLord> sameLordList;

    public long getRoleId() {
        return roleId;
    }

    public void setRoleId(long roleId) {
        this.roleId = roleId;
    }

    public List<SameLord> getSameLordList() {
        return sameLordList;
    }

    public void setSameLordList(List<SameLord> sameLordList) {
        this.sameLordList = sameLordList;
    }
}

class SameLord {

    private long roleId;
    private String name;
    private int level;
    private int serverId;
    private MServer slave;
    private long createTime;

    public long getRoleId() {
        return roleId;
    }

    public void setRoleId(long roleId) {
        this.roleId = roleId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public int getServerId() {
        return serverId;
    }

    public void setServerId(int serverId) {
        this.serverId = serverId;
    }

    public MServer getSlave() {
        return slave;
    }

    public void setSlave(MServer slave) {
        this.slave = slave;
    }

    public long getCreateTime() {
        return createTime;
    }

    public void setCreateTime(long createTime) {
        this.createTime = createTime;
    }
}