package com.game.domain.p.saveplayerinfo;


/**
 * @ClassName:SaveMilitaryScience
 * @author zc
 * @Description:军工科技
 * @date 2017年12月4日
 */
public class SaveMilitaryScience {
    private int tankId;
    private int count;

    public SaveMilitaryScience(int tankId, int count) {
        this.tankId = tankId;
        this.count = count;
    }

    public long getMem() {
        return 32 * 2;
    }

    public int getTankId() {
        return tankId;
    }

    public void setTankId(int tankId) {
        this.tankId = tankId;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }
}
