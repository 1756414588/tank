package com.game.domain;

/**
 * @ClassName:Skin
 * @author zc
 * @Description:
 * @date 2017年9月23日
 */
public class Skin {
    private int skinId;
    private int count;

    public Skin(int skinId, int count) {
        this.skinId = skinId;
        this.count = count;
    }
    
    public int getSkinId() {
        return skinId;
    }

    public void setSkinId(int skinId) {
        this.skinId = skinId;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }
}
