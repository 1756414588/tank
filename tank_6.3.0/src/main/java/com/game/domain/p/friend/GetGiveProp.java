package com.game.domain.p.friend;

/**
 * 玩家获赠道具
 */
public class GetGiveProp {

    private int type;

    /**
     * 道具ID
     */
    private int propId;
    /**
     * 获赠数量
     */
    private int num;
    /**
     * 最后一次获赠时间
     */
    private long lastGiveTime;

    public GetGiveProp(int type, int propId, int num, long lastGiveTime) {
        this.type = type;
        this.propId = propId;
        this.num = num;
        this.lastGiveTime = lastGiveTime;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public int getPropId() {
        return propId;
    }

    public void setPropId(int propId) {
        this.propId = propId;
    }

    public int getNum() {
        return num;
    }

    public void setNum(int num) {
        this.num = num;
    }

    public long getLastGiveTime() {
        return lastGiveTime;
    }

    public void setLastGiveTime(long lastGiveTime) {
        this.lastGiveTime = lastGiveTime;
    }
}
