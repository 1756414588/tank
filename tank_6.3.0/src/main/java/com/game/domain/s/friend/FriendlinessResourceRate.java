package com.game.domain.s.friend;

/**
 * 好友度资源掠夺比例
 */
public class FriendlinessResourceRate {

    /**
     * 好友度下限
     */
    private int min;
    /**
     * 好友度上限
     */
    private int max;
    /**
     * 掠夺比例
     */
    private int rate;

    public FriendlinessResourceRate(int min, int max, int rate) {
        this.min = min;
        this.max = max;
        this.rate = rate;
    }

    public int getMin() {
        return min;
    }

    public void setMin(int min) {
        this.min = min;
    }

    public int getMax() {
        return max;
    }

    public void setMax(int max) {
        this.max = max;
    }

    public int getRate() {
        return rate;
    }

    public void setRate(int rate) {
        this.rate = rate;
    }
}
