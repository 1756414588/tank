package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-1 上午11:30:16
 * @Description: 玩家的将领
 */

public class Hero {

    private int keyId;
    private int heroId;
    private int count;
    private long endTime;
    private long cd;


    public int getKeyId() {
        return keyId;
    }

    public void setKeyId(int keyId) {
        this.keyId = keyId;
    }

    public int getHeroId() {
        return heroId;
    }

    public void setHeroId(int heroId) {
        this.heroId = heroId;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public long getEndTime() {
        return endTime;
    }

    public void setEndTime(long endTime) {
        this.endTime = endTime;
    }

    public Hero(int keyId, int heroId, int count) {
        this.keyId = keyId;
        this.heroId = heroId;
        this.count = count;
    }

    public long getCd() {
        return cd;
    }

    public void setCd(long cd) {
        this.cd = cd;
    }
}
