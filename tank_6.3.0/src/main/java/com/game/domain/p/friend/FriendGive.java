package com.game.domain.p.friend;

/**
 * 好友赠送
 */
public class FriendGive {
    /**
     * 玩家ID
     */
    private long lordId;
    /**
     * 赠送次数
     */
    private int count;
    /**
     * 最近一次赠送时间
     */
    private long giveTime;

    public long getLordId() {
        return lordId;
    }

    public void setLordId(long lordId) {
        this.lordId = lordId;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public long getGiveTime() {
        return giveTime;
    }

    public void setGiveTime(int giveTime) {
        this.giveTime = giveTime;
    }

    public FriendGive(long lordId, int count, long giveTime) {
        this.lordId = lordId;
        this.count = count;
        this.giveTime = giveTime;
    }
}
