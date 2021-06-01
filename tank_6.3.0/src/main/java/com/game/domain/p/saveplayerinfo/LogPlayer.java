package com.game.domain.p.saveplayerinfo;

import java.util.Date;
import java.util.LinkedList;
import java.util.List;

import com.game.domain.p.MilitaryMaterial;

/**
 * @ClassName:SavePlayerInfo
 * @author zc
 * @Description:记录玩家信息实体
 * @date 2017年9月19日
 */
public class LogPlayer {
    private long lordId;
    private String nick;
    private int serverId;
    private int gold;
    private int lv;
    private int vip;
    private long fight;
    private long lastLoginDay;

    private List<SaveMedal> medalList = new LinkedList<>();
    private List<SaveLordEquip> lordEquipList = new LinkedList<>();
    private List<SaveEquip> equipList = new LinkedList<>();
    private List<SaveParts> partsList = new LinkedList<>();
    private List<SaveEnergyStone> energyStoneList = new LinkedList<>();
    private List<SaveMilitaryScience> militarySciencetList = new LinkedList<>();
    private List<MilitaryMaterial> militaryMaterialList = new LinkedList<>();
    
    public long getMem() {
        long mem = 64 * 6 + 32 * 4;
        for (SaveMedal save : medalList) {
            mem += save.getMem();
        }
        for (SaveLordEquip save : lordEquipList) {
            mem += save.getMem();
        }
        for (SaveEquip save : equipList) {
            mem += save.getMem();
        }
        for (SaveParts save : partsList) {
            mem += save.getMem();
        }
        for (SaveEnergyStone save : energyStoneList) {
            mem += save.getMem();
        }
        for (SaveMilitaryScience save : militarySciencetList) {
            mem += save.getMem();
        }
        for (MilitaryMaterial save : militaryMaterialList) {
            mem += 32 * 2;
        }
        mem += 64 * (medalList.size() + lordEquipList.size() + equipList.size() + partsList.size()
                + energyStoneList.size() + militarySciencetList.size() + militaryMaterialList.size());
        return mem;
    }

    public LogPlayer(long lordId) {
        this.lordId = lordId;
    }

    public void addMedal(int medalId, int medalUpLv, int medalRefitLv) {
        medalList.add(new SaveMedal(medalId, medalUpLv, medalRefitLv));
    }

    public void addLordEquip(int equipId, int equipLv, List<List<Integer>> lordEquipSkillList) {
        lordEquipList.add(new SaveLordEquip(equipId, equipLv, lordEquipSkillList));
    }

    public void addEquip(int equipId, int lv) {
        equipList.add(new SaveEquip(equipId, lv));
    }

    public long getLordId() {
        return lordId;
    }

    public void setLordId(long lordId) {
        this.lordId = lordId;
    }

    public List<SaveMedal> getMedalList() {
        return medalList;
    }

    public void setMedalList(List<SaveMedal> medalList) {
        this.medalList = medalList;
    }

    public List<SaveLordEquip> getLordEquipList() {
        return lordEquipList;
    }

    public void setLordEquipList(List<SaveLordEquip> lordEquipList) {
        this.lordEquipList = lordEquipList;
    }

    public String getNick() {
        return nick;
    }

    public void setNick(String nick) {
        this.nick = nick;
    }

    public int getServerId() {
        return serverId;
    }

    public void setServerId(int serverId) {
        this.serverId = serverId;
    }

    public int getGold() {
        return gold;
    }

    public void setGold(int gold) {
        this.gold = gold;
    }

    public int getLv() {
        return lv;
    }

    public void setLv(int lv) {
        this.lv = lv;
    }

    public int getVip() {
        return vip;
    }

    public void setVip(int vip) {
        this.vip = vip;
    }

    public long getFight() {
        return fight;
    }

    public void setFight(long fight) {
        this.fight = fight;
    }

    public long getLastLoginDay() {
        return lastLoginDay;
    }

    public void setLastLoginDay(Date date) {
        if (date == null) {
            this.lastLoginDay = 0;
        } else {
            this.lastLoginDay = date.getTime();
        }
    }

    public List<SaveEquip> getEquipList() {
        return equipList;
    }

    public void addPart(int partId, int upLv, int refitLv, int smeltLv, int pos) {
        partsList.add(new SaveParts(partId, upLv, refitLv, smeltLv, pos));
    }

    public List<SaveParts> getPartsList() {
        return partsList;
    }

    public void addEnergyStone(int propId, int count) {
        energyStoneList.add(new SaveEnergyStone(propId, count));
    }

    public List<SaveEnergyStone> getEnergyStoneList() {
        return energyStoneList;
    }

    public void addScience(int tankId, int count) {
        militarySciencetList.add(new SaveMilitaryScience(tankId, count));
    }
    
    public List<SaveMilitaryScience> getMilitaryScienceList() {
        return militarySciencetList;
    }

    public void addMilitaryMaterial(int id, long count) {
        militaryMaterialList.add(new MilitaryMaterial(id, count));
    }
    
    public List<MilitaryMaterial> getMilitaryMaterialList() {
        return militaryMaterialList;
    }
}
