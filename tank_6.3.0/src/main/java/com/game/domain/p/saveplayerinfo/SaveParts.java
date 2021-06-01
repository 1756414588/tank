package com.game.domain.p.saveplayerinfo;

/**
 * @ClassName:SaveParts
 * @author zc
 * @Description:配件
 * @date 2017年12月1日
 */
public class SaveParts {
    private int partId;
    private int upLv;
    private int refitLv;
    private int pos;
    private int smeltLv;

    public SaveParts(int partId, int upLv, int refitLv, int smeltLv, int pos) {
        this.partId = partId;
        this.upLv = upLv;
        this.refitLv = refitLv;
        this.smeltLv = smeltLv;
        this.pos = pos;
    }
    
    public long getMem() {
        return 32 * 5;
    }

    public int getPartId() {
        return partId;
    }

    public void setPartId(int partId) {
        this.partId = partId;
    }

    public int getUpLv() {
        return upLv;
    }

    public void setUpLv(int upLv) {
        this.upLv = upLv;
    }

    public int getRefitLv() {
        return refitLv;
    }

    public void setRefitLv(int refitLv) {
        this.refitLv = refitLv;
    }

    public int getPos() {
        return pos;
    }

    public void setPos(int pos) {
        this.pos = pos;
    }

    public int getSmeltLv() {
        return smeltLv;
    }

    public void setSmeltLv(int smeltLv) {
        this.smeltLv = smeltLv;
    }
}
