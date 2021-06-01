package com.game.domain.p.saveplayerinfo;

/**
 * @ClassName:SaveEnergyStone
 * @author zc
 * @Description: 能晶信息
 * @date 2017年12月4日
 */
public class SaveEnergyStone {
    private int propId;
    private int count;

    public SaveEnergyStone(int propId, int count) {
        this.propId = propId;
        this.count = count;
    }

    public long getMem() {
        return 32 * 4;
    }

    public int getPropId() {
        return propId;
    }

    public void setPropId(int propId) {
        this.propId = propId;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }
}
