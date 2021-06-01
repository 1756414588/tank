package com.game.cross.domain;

import com.game.domain.PEnergyCore;
import com.game.domain.p.*;
import com.game.domain.p.lordequip.LordEquip;

import java.util.*;

/**
 * @Author :GuiJie Liu
 * @date :Create in 2019/3/13 15:45 @Description :java类作用描述
 */
public class Athlete {
    /**
     * 由于代码不规范 所以加一个 数据被修改状态 根据该状态定时存库
     */
    private boolean isUpdate;
    private int serverId;
    private long roleId;
    private String nick;
    private int groupId;
    private long fight;
    private int level;
    private int winNum = 0;
    private int failNum = 0;
    private int portrait;
    private String partyName;
    /**
     * 我的战报key
     */
    private List<Integer> myReportKeys = new ArrayList<Integer>();
    public Map<Integer, Form> forms = new HashMap<Integer, Form>();
    public HashMap<Integer, HashMap<Integer, Equip>> equips = new HashMap<Integer, HashMap<Integer, Equip>>();
    public HashMap<Integer, Science> sciences = new HashMap<Integer, Science>();
    public HashMap<Integer, HashMap<Integer, Part>> parts = new HashMap<Integer, HashMap<Integer, Part>>();
    public HashMap<Integer, Integer> skills = new HashMap<Integer, Integer>();
    public HashMap<Integer, Effect> effects = new HashMap<Integer, Effect>();
    /**
     * 编制id
     */
    public int StaffingId;
    /**
     * 能晶镶嵌信息
     */
    public Map<Integer, Map<Integer, EnergyStoneInlay>> energyInlay = new HashMap<Integer, Map<Integer, EnergyStoneInlay>>();
    /**
     * 军工科技 (科技id,科技信息)
     */
    public HashMap<Integer, MilitaryScience> militarySciences = new HashMap<Integer, MilitaryScience>();
    /**
     * 军工科技格子状态(tankId,pos,状态)
     */
    public HashMap<Integer, HashMap<Integer, MilitaryScienceGrid>> militaryScienceGrids = new HashMap<Integer, HashMap<Integer, MilitaryScienceGrid>>();
    /**
     * 勋章数据
     */
    public HashMap<Integer, HashMap<Integer, Medal>> medals = new HashMap<>();
    /**
     * 勋章展示数据
     */
    public HashMap<Integer, HashMap<Integer, MedalBouns>> medalBounss = new HashMap<>();
    /**
     * 将领觉醒集合
     */
    public HashMap<Integer, AwakenHero> awakenHeros = new HashMap<>();
    /**
     * 军备
     */
    public Map<Integer, LordEquip> lordEquips = new HashMap<>();
    /**
     * 军衔等级
     */
    public int militaryRank;
    /**
     * 秘密武器信息
     */
    public TreeMap<Integer, SecretWeapon> secretWeaponMap = new TreeMap<>();
    /**
     * 攻击特效
     */
    public Map<Integer, AttackEffect> atkEffects = new HashMap<>();
    /**
     * 作战实验室科技树
     */
    public Map<Integer, Map<Integer, Integer>> graduateInfo = new HashMap<>();
    private List<Long> historyRoleId = new ArrayList<>();
    /**
     * 军团科技列表
     */
    public Map<Integer, PartyScience> partyScienceMap = new HashMap<>();

    private PEnergyCore pEnergyCore = new PEnergyCore();

    public int getServerId() {
        return serverId;
    }

    public void setServerId(int serverId) {
        this.serverId = serverId;
    }

    public long getRoleId() {
        return roleId;
    }

    public void setRoleId(long roleId) {
        this.roleId = roleId;
    }

    public String getNick() {
        return nick;
    }

    public void setNick(String nick) {
        this.nick = nick;
    }

    public int getGroupId() {
        return groupId;
    }

    public void setGroupId(int groupId) {
        this.groupId = groupId;
    }

    public long getFight() {
        return fight;
    }

    public void setFight(long fight) {
        this.fight = fight;
    }

    public Map<Integer, Form> getForms() {
        return forms;
    }

    public void setForms(Map<Integer, Form> forms) {
        this.forms = forms;
    }

    public List<Integer> getMyReportKeys() {
        return myReportKeys;
    }

    public void setMyReportKeys(List<Integer> myReportKeys) {
        this.myReportKeys = myReportKeys;
    }

    public void addReportKey(int reportKey) {
        myReportKeys.add(reportKey);
        this.isUpdate = true;
    }

    public int getWinNum() {
        return winNum;
    }

    public void setWinNum(int winNum) {
        this.winNum = winNum;
        this.isUpdate = true;
    }

    public int getFailNum() {
        return failNum;
    }

    public void setFailNum(int failNum) {
        this.failNum = failNum;
        this.isUpdate = true;
    }

    public int getStaffingId() {
        return StaffingId;
    }

    public void setStaffingId(int staffingId) {
        StaffingId = staffingId;
    }

    public int getPortrait() {
        return portrait;
    }

    public void setPortrait(int portrait) {
        this.portrait = portrait;
    }

    public String getPartyName() {
        return partyName;
    }

    public void setPartyName(String partyName) {
        this.partyName = partyName;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public List<Long> getHistoryRoleId() {
        return historyRoleId;
    }

    public void setHistoryRoleId(List<Long> historyRoleId) {
        this.historyRoleId = historyRoleId;
    }

    public boolean isUpdate() {
        return isUpdate;
    }

    public void setUpdate(boolean update) {
        isUpdate = update;
    }

    public PEnergyCore getpEnergyCore() {
        return pEnergyCore;
    }

    public void setpEnergyCore(PEnergyCore pEnergyCore) {
        this.pEnergyCore = pEnergyCore;
    }
}