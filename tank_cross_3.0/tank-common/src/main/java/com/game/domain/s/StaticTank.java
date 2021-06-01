/**
 * @Title: StaticTank.java @Package com.game.domain.s @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年7月17日 下午2:34:34
 * @version V1.0
 */
package com.game.domain.s;

import java.util.List;
import java.util.Map;

/**
 * @ClassName: StaticTank @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年7月17日 下午2:34:34
 */
public class StaticTank {
  private int tankId;
  private String name;
  private int type;
  private int subType;
  private int grade;
  private int honorScore;
  private int warScore;
  private int canBuild;
  private int canRefit;
  private int buildTime;
  private int lordLv;
  private int factoryLv;
  private int refitLv;
  private int refitId;
  private int drawing;
  private int book;
  private int iron;
  private int oil;
  private int copper;
  private int silicon;
  private int repair;
  private int payload;
  private int fight;
  private int attackMode;
  private int attack;
  private long hp;
  private int hit;
  private int dodge;
  private int crit;
  private int critDef;
  private int impale;
  private int defend;
  private float attckFactor;
  private float hpFactor;
  private int impaleFactor;
  private int staffingExp;
  private Map<Integer, Integer> restriction;
  private List<Integer> aura;
  private List<StaticBuff> buffs;
  private long lostMilitary;//己方永久损失的部队获得的军功
  private long destroyMilitary;//造成敌方永久损失后己方获得的军功
  private int honourLiveScore;//荣耀玩法炸矿战损对应的积分系数

  public int getTankId() {
    return tankId;
  }

  public void setTankId(int tankId) {
    this.tankId = tankId;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public int getType() {
    return type;
  }

  public void setType(int type) {
    this.type = type;
  }

  public int getSubType() {
    return subType;
  }

  public void setSubType(int subType) {
    this.subType = subType;
  }

  public int getGrade() {
    return grade;
  }

  public void setGrade(int grade) {
    this.grade = grade;
  }

  public int getCanBuild() {
    return canBuild;
  }

  public void setCanBuild(int canBuild) {
    this.canBuild = canBuild;
  }

  public int getBuildTime() {
    return buildTime;
  }

  public void setBuildTime(int buildTime) {
    this.buildTime = buildTime;
  }

  public int getLordLv() {
    return lordLv;
  }

  public void setLordLv(int lordLv) {
    this.lordLv = lordLv;
  }

  public int getFactoryLv() {
    return factoryLv;
  }

  public void setFactoryLv(int factoryLv) {
    this.factoryLv = factoryLv;
  }

  public int getDrawing() {
    return drawing;
  }

  public void setDrawing(int drawing) {
    this.drawing = drawing;
  }

  public int getBook() {
    return book;
  }

  public void setBook(int book) {
    this.book = book;
  }

  public int getIron() {
    return iron;
  }

  public void setIron(int iron) {
    this.iron = iron;
  }

  public int getOil() {
    return oil;
  }

  public void setOil(int oil) {
    this.oil = oil;
  }

  public int getCopper() {
    return copper;
  }

  public void setCopper(int copper) {
    this.copper = copper;
  }

  public int getSilicon() {
    return silicon;
  }

  public void setSilicon(int silicon) {
    this.silicon = silicon;
  }

  public int getRepair() {
    return repair;
  }

  public void setRepair(int repair) {
    this.repair = repair;
  }

  public int getPayload() {
    return payload;
  }

  public void setPayload(int payload) {
    this.payload = payload;
  }

  public int getFight() {
    return fight;
  }

  public void setFight(int fight) {
    this.fight = fight;
  }

  public int getAttackMode() {
    return attackMode;
  }

  public void setAttackMode(int attackMode) {
    this.attackMode = attackMode;
  }

  public int getAttack() {
    return attack;
  }

  public void setAttack(int attack) {
    this.attack = attack;
  }

  public long getHp() {
    return hp;
  }

  public void setHp(long hp) {
    this.hp = hp;
  }

  public int getHit() {
    return hit;
  }

  public void setHit(int hit) {
    this.hit = hit;
  }

  public int getDodge() {
    return dodge;
  }

  public void setDodge(int dodge) {
    this.dodge = dodge;
  }

  public int getCrit() {
    return crit;
  }

  public void setCrit(int crit) {
    this.crit = crit;
  }

  public int getCritDef() {
    return critDef;
  }

  public void setCritDef(int critDef) {
    this.critDef = critDef;
  }

  public int getImpale() {
    return impale;
  }

  public void setImpale(int impale) {
    this.impale = impale;
  }

  public int getDefend() {
    return defend;
  }

  public void setDefend(int defend) {
    this.defend = defend;
  }

  public Map<Integer, Integer> getRestriction() {
    return restriction;
  }

  public void setRestriction(Map<Integer, Integer> restriction) {
    this.restriction = restriction;
  }

  public List<Integer> getAura() {
    return aura;
  }

  public void setAura(List<Integer> aura) {
    this.aura = aura;
  }

  public int getCanRefit() {
    return canRefit;
  }

  public void setCanRefit(int canRefit) {
    this.canRefit = canRefit;
  }

  public int getRefitLv() {
    return refitLv;
  }

  public void setRefitLv(int refitLv) {
    this.refitLv = refitLv;
  }

  public int getRefitId() {
    return refitId;
  }

  public void setRefitId(int refitId) {
    this.refitId = refitId;
  }

  public List<StaticBuff> getBuffs() {
    return buffs;
  }

  public void setBuffs(List<StaticBuff> buffs) {
    this.buffs = buffs;
  }

  public float getAttckFactor() {
    return attckFactor;
  }

  public void setAttckFactor(float attckFactor) {
    this.attckFactor = attckFactor;
  }

  public float getHpFactor() {
    return hpFactor;
  }

  public void setHpFactor(float hpFactor) {
    this.hpFactor = hpFactor;
  }

  public int getHonorScore() {
    return honorScore;
  }

  public void setHonorScore(int honorScore) {
    this.honorScore = honorScore;
  }

  public int getImpaleFactor() {
    return impaleFactor;
  }

  public void setImpaleFactor(int impaleFactor) {
    this.impaleFactor = impaleFactor;
  }

  public int getWarScore() {
    return warScore;
  }

  public void setWarScore(int warScore) {
    this.warScore = warScore;
  }

  public int getStaffingExp() {
    return staffingExp;
  }

  public void setStaffingExp(int staffingExp) {
    this.staffingExp = staffingExp;
  }

  public long getLostMilitary() {
    return lostMilitary;
  }

  public void setLostMilitary(long lostMilitary) {
    this.lostMilitary = lostMilitary;
  }

  public long getDestroyMilitary() {
    return destroyMilitary;
  }

  public void setDestroyMilitary(long destroyMilitary) {
    this.destroyMilitary = destroyMilitary;
  }

  public int getHonourLiveScore() {
    return honourLiveScore;
  }

  public void setHonourLiveScore(int honourLiveScore) {
    this.honourLiveScore = honourLiveScore;
  }
}
