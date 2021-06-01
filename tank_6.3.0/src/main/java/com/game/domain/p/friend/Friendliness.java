package com.game.domain.p.friend;

/**
 * 友好度
 */
public class Friendliness {
    /**
     * 玩家ID
     */
    private long lordId;
    /**
     * 状态0：祝福未加友好度
     */
    private int state;
    /**
     * 加友好度时间
     */
    private int createTime;

    public Friendliness(long lordId, int state, int createTime) {
        this.lordId = lordId;
        this.state = state;
        this.createTime = createTime;
    }

    public long getLordId() {
        return lordId;
    }

    public void setLordId(long lordId) {
        this.lordId = lordId;
    }

    public int getState() {
        return state;
    }

    public void setState(int state) {
        this.state = state;
    }

    public int getCreateTime() {
        return createTime;
    }

    public void setCreateTime(int createTime) {
        this.createTime = createTime;
    }
}
