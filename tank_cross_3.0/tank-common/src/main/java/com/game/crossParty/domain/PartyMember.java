package com.game.crossParty.domain;

import com.game.cross.domain.CrossShopBuy;
import com.game.cross.domain.CrossTrend;
import com.game.domain.PEnergyCore;
import com.game.domain.p.*;
import com.game.domain.p.lordequip.LordEquip;

import java.util.*;

public class PartyMember {
  private int serverId;
  private long roleId;
  private String nick;
  private long fight;
  private int level;

  private int groupWinNum = 0;
  private int finalWinNum = 0;
  private int fightCount = 0;

  private int partyId;
  private String partyName;
  private int jifen;

  private int jifenjiangli;

  private int exchangeJifen = 0;

  private int regTime;

  private int portrait;

  private List<Integer> myReportKeys = new ArrayList<Integer>(); // 我的战报key

  // 跨服商店商品购买记录
  public Map<Integer, CrossShopBuy> crossShopBuy = new HashMap<>();

  // 跨服战积分详情
  public List<CrossTrend> crossTrends = new ArrayList<CrossTrend>();

  private Form form;

  public HashMap<Integer, HashMap<Integer, Equip>> equips =
      new HashMap<Integer, HashMap<Integer, Equip>>();

  public HashMap<Integer, Science> sciences = new HashMap<Integer, Science>();

  public HashMap<Integer, HashMap<Integer, Part>> parts =
      new HashMap<Integer, HashMap<Integer, Part>>();

  public HashMap<Integer, Integer> skills = new HashMap<Integer, Integer>();

  public HashMap<Integer, Effect> effects = new HashMap<Integer, Effect>();

  // 勋章数据
  public HashMap<Integer, HashMap<Integer, Medal>> medals = new HashMap<>();

  // 勋章展示数据
  public HashMap<Integer, HashMap<Integer, MedalBouns>> medalBounss = new HashMap<>();

  // 将领觉醒集合
  public HashMap<Integer, AwakenHero> awakenHeros = new HashMap<>();

  // 军备信息
  public Map<Integer, LordEquip> lordEquips = new HashMap<>();

  // 玩家军衔等级
  public int militaryRank;

  // 秘密武器
  public TreeMap<Integer, SecretWeapon> secretWeaponMap = new TreeMap<>();

  // 攻击特效
  public Map<Integer, AttackEffect> atkEffects = new HashMap<>();

  // 作战实验室科技树
  public Map<Integer, Map<Integer, Integer>> graduateInfo = new HashMap<>();

  public int getPortrait() {
    return portrait;
  }

  public void setPortrait(int portrait) {
    this.portrait = portrait;
  }

  // 编制id
  public int StaffingId;

  // 能晶镶嵌信息
  public Map<Integer, Map<Integer, EnergyStoneInlay>> energyInlay =
      new HashMap<Integer, Map<Integer, EnergyStoneInlay>>();

  // 军工科技 (科技id,科技信息)
  public HashMap<Integer, MilitaryScience> militarySciences =
      new HashMap<Integer, MilitaryScience>();

  // 军工科技格子状态(tankId,pos,状态)
  public HashMap<Integer, HashMap<Integer, MilitaryScienceGrid>> militaryScienceGrids =
      new HashMap<Integer, HashMap<Integer, MilitaryScienceGrid>>();

  /** 军团科技列表 */
  public Map<Integer, PartyScience> partyScienceMap = new HashMap<>();

  /** @Fields state : 参战状态，0.未出局 1.已出局 */
  private int state;
  // private int winCount;
  private Form instForm;

  private PEnergyCore pEnergyCore = new PEnergyCore();

  public Form getForm() {
    return form;
  }

  public int getFightCount() {
    return fightCount;
  }

  public void setFightCount(int fightCount) {
    this.fightCount = fightCount;
  }

  public void setForm(Form form) {
    this.form = form;
  }

  public int getRegTime() {
    return regTime;
  }

  public int getExchangeJifen() {
    return exchangeJifen;
  }

  public void setExchangeJifen(int exchangeJifen) {
    this.exchangeJifen = exchangeJifen;
  }

  public void setRegTime(int regTime) {
    this.regTime = regTime;
  }

  public Form getInstForm() {
    return instForm;
  }

  public List<CrossTrend> getCrossTrends() {
    return crossTrends;
  }

  public void setCrossTrends(List<CrossTrend> crossTrends) {
    this.crossTrends = crossTrends;
  }

  public void setInstForm(Form instForm) {
    this.instForm = instForm;
  }

  public int getServerId() {
    return serverId;
  }

  public int getPartyId() {
    return partyId;
  }

  public void setPartyId(int partyId) {
    this.partyId = partyId;
  }

  public int getLevel() {
    return level;
  }

  public void setLevel(int level) {
    this.level = level;
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

  public long getFight() {
    return fight;
  }

  public void setFight(long fight) {
    this.fight = fight;
  }

  public List<Integer> getMyReportKeys() {
    return myReportKeys;
  }

  public void setMyReportKeys(List<Integer> myReportKeys) {
    this.myReportKeys = myReportKeys;
  }

  public void addReportKey(int reportKey) {
    myReportKeys.add(reportKey);
  }

  public int getGroupWinNum() {
    return groupWinNum;
  }

  public void setGroupWinNum(int groupWinNum) {
    this.groupWinNum = groupWinNum;
  }

  public int getFinalWinNum() {
    return finalWinNum;
  }

  public void setFinalWinNum(int finalWinNum) {
    this.finalWinNum = finalWinNum;
  }

  public int getStaffingId() {
    return StaffingId;
  }

  public void setStaffingId(int staffingId) {
    StaffingId = staffingId;
  }

  public int getState() {
    return state;
  }

  public void setState(int state) {
    this.state = state;
  }

  public String getPartyName() {
    return partyName;
  }

  public int getJifen() {
    return jifen;
  }

  public void setJifen(int jifen) {
    if (jifen > 5000) {
      jifen = 5000;
    }
    this.jifen = jifen;
  }

  public void setPartyName(String partyName) {
    this.partyName = partyName;
  }

  public void addKey(int key) {
    myReportKeys.add(key);
  }

  public PEnergyCore getpEnergyCore() {
    return pEnergyCore;
  }

  public void setpEnergyCore(PEnergyCore pEnergyCore) {
    this.pEnergyCore = pEnergyCore;
  }

  public int calcHp() {
    Form baseForm = getForm();
    Form curForm = getInstForm();
    int base =
        baseForm.c[0]
            + baseForm.c[1]
            + baseForm.c[2]
            + baseForm.c[3]
            + baseForm.c[4]
            + baseForm.c[5];
    int cur =
        curForm.c[0] + curForm.c[1] + curForm.c[2] + curForm.c[3] + curForm.c[4] + curForm.c[5];
    return cur * 100 / base;
  }

  public Map<Integer, CrossShopBuy> getCrossShopBuy() {
    return crossShopBuy;
  }

  public void setCrossShopBuy(Map<Integer, CrossShopBuy> crossShopBuy) {
    this.crossShopBuy = crossShopBuy;
  }

  public HashMap<Integer, HashMap<Integer, Equip>> getEquips() {
    return equips;
  }

  public void setEquips(HashMap<Integer, HashMap<Integer, Equip>> equips) {
    this.equips = equips;
  }

  public HashMap<Integer, Science> getSciences() {
    return sciences;
  }

  public void setSciences(HashMap<Integer, Science> sciences) {
    this.sciences = sciences;
  }

  public HashMap<Integer, HashMap<Integer, Part>> getParts() {
    return parts;
  }

  public void setParts(HashMap<Integer, HashMap<Integer, Part>> parts) {
    this.parts = parts;
  }

  public HashMap<Integer, Integer> getSkills() {
    return skills;
  }

  public void setSkills(HashMap<Integer, Integer> skills) {
    this.skills = skills;
  }

  public HashMap<Integer, Effect> getEffects() {
    return effects;
  }

  public void setEffects(HashMap<Integer, Effect> effects) {
    this.effects = effects;
  }

  public Map<Integer, Map<Integer, EnergyStoneInlay>> getEnergyInlay() {
    return energyInlay;
  }

  public void setEnergyInlay(Map<Integer, Map<Integer, EnergyStoneInlay>> energyInlay) {
    this.energyInlay = energyInlay;
  }

  public HashMap<Integer, MilitaryScience> getMilitarySciences() {
    return militarySciences;
  }

  public void setMilitarySciences(HashMap<Integer, MilitaryScience> militarySciences) {
    this.militarySciences = militarySciences;
  }

  public HashMap<Integer, HashMap<Integer, MilitaryScienceGrid>> getMilitaryScienceGrids() {
    return militaryScienceGrids;
  }

  public void setMilitaryScienceGrids(
      HashMap<Integer, HashMap<Integer, MilitaryScienceGrid>> militaryScienceGrids) {
    this.militaryScienceGrids = militaryScienceGrids;
  }

  public int getJifenjiangli() {
    return jifenjiangli;
  }

  public void setJifenjiangli(int jifenjiangli) {
    this.jifenjiangli = jifenjiangli;
  }

  public String getKey() {

    return serverId + "_" + roleId;
  }
}
