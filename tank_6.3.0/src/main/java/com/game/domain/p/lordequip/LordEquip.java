package com.game.domain.p.lordequip;

import com.game.domain.p.Equip;

import java.util.ArrayList;
import java.util.List;

/**
 * @author zhangdh
 * @ClassName: lordequip
 * @Description: 指挥官装备(注意与阵形格子装备区分开来)
 * @date 2017/4/20 16:45
 */
public class LordEquip extends Equip {
    private int star;//洗练的星数

    //军备洗练出的技能id列表
    private List<List<Integer>> lordEquipSkillList = new ArrayList<List<Integer>>();
    private List<List<Integer>> lordEquipSkillSecondList = new ArrayList<List<Integer>>();

    private boolean isLock;

    //军备保存的是第几套  0第一套，1第二套
    private int lordEquipSaveType;

    public LordEquip(int keyId, int equipId) {
        super(keyId, equipId, 0,0,0);
    }

    public LordEquip(int keyId, int equipId, int pos) {
        super(keyId, equipId, 0,0,pos);
    }

    public int getStar() {
        return star;
    }

    public void setStar(int star) {
        this.star = star;
    }
    
    public List<List<Integer>> getLordEquipSkillList() {
		return lordEquipSkillList;
	}

    public void setLordEquipSkillList(List<List<Integer>> lordEquipSkillList) {
        this.lordEquipSkillList = lordEquipSkillList;
    }

    public boolean isLock() {
        return isLock;
    }

    public void setLock(boolean lock) {
        isLock = lock;
    }

    public List<List<Integer>> getLordEquipSkillSecondList() {
        return lordEquipSkillSecondList;
    }

    public void setLordEquipSkillSecondList(List<List<Integer>> lordEquipSkillSecondList) {
        this.lordEquipSkillSecondList = lordEquipSkillSecondList;
    }

    public int getLordEquipSaveType() {
        return lordEquipSaveType;
    }

    public void setLordEquipSaveType(int lordEquipSaveType) {
        this.lordEquipSaveType = lordEquipSaveType;
    }

    @Override
    public String toString() {
        return String.format("id :%d, equip id :%d, pos :%d, star :%s", keyId, equipId, pos, star);
    }
}
