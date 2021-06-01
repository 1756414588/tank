package com.game.domain.p.repair;

/**
 * 成长基金扣除玩家金币处理
 * @author zhangdh
 * @ClassName: InvestNew
 * @Description:
 * @date 2017-07-27 19:45
 */
public class InvestNew {
    private int uid;
    private int serverId;
    private long lordId;
    private String nick;
    private int needSub;//需要扣除的金币
    private int flag;//1-已经处理过的玩家
    private int alreadySub;//已经扣除的金币
    private int remain;//玩家身上剩余金币

    public int getServerId() {
        return serverId;
    }

    public void setServerId(int serverId) {
        this.serverId = serverId;
    }

    public long getLordId() {
        return lordId;
    }

    public String getNick() {
        return nick;
    }

    public void setNick(String nick) {
        this.nick = nick;
    }

    public void setLordId(long lordId) {
        this.lordId = lordId;
    }

    public int getNeedSub() {
        return needSub;
    }

    public void setNeedSub(int needSub) {
        this.needSub = needSub;
    }

    public int getAlreadySub() {
        return alreadySub;
    }

    public void setAlreadySub(int alreadySub) {
        this.alreadySub = alreadySub;
    }

    public int getUid() {
        return uid;
    }

    public void setUid(int uid) {
        this.uid = uid;
    }

    public int getRemain() {
        return remain;
    }

    public void setRemain(int remain) {
        this.remain = remain;
    }

    public int getFlag() {
        return flag;
    }

    public void setFlag(int flag) {
        this.flag = flag;
    }

    @Override
    public String toString() {
        return "InvestNew{" +
                "uid=" + uid +
                ", serverId=" + serverId +
                ", lordId=" + lordId +
                ", nick='" + nick + '\'' +
                ", needSub=" + needSub +
                ", flag=" + flag +
                ", alreadySub=" + alreadySub +
                ", remain=" + remain +
                '}';
    }
}
