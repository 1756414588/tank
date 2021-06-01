package com.game.domain.p.saveplayerinfo;

/**
 * @ClassName:SaveLordEquip
 * @author zc
 * @Description:装备信息
 * @date 2017年12月1日
 */
public class SaveEquip {
    private int equipId;// 装备id
    private int equipLv;// 装备等级
    
    public SaveEquip(int id, int lv) {
        this.equipId = id;
        this.equipLv = lv;
    }
    
    public long getMem() {
        return 32 * 2;
    }

    public int getEquipId() {
        return equipId;
    }

    public void setEquipId(int equipId) {
        this.equipId = equipId;
    }

    public int getEquipLv() {
        return equipLv;
    }

    public void setEquipLv(int equipLv) {
        this.equipLv = equipLv;
    }
    
}
