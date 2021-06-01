package com.game.domain.s;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2015-8-31 下午4:44:01
 * @declare
 */
public class StaticHero {
  private int heroId;
  private String heroName;
  private int type;
  private int star;
  private int level;
  private int heroAdditionId;
  private int resolveId;
  private int soul;
  private int canup;
  private List<List<Integer>> meta;
  private List<List<Integer>> attr;
  private int skillId;
  private int skillValue;
  private int tankCount;
  private int order;
  private int compound;
  private int probability;
  private int awakenHeroId;
  private String awakenCond;
  private List<Integer> awakenSkillArr;
  private List<Integer> cost1;
  private int upProb1;
  private List<Integer> cost2;
  private int upProb2;
  private int failTimes;
  private int commanderLv;

  public int getHeroId() {
    return heroId;
  }

  public void setHeroId(int heroId) {
    this.heroId = heroId;
  }

  public String getHeroName() {
    return heroName;
  }

  public void setHeroName(String heroName) {
    this.heroName = heroName;
  }

  public int getType() {
    return type;
  }

  public void setType(int type) {
    this.type = type;
  }

  public int getStar() {
    return star;
  }

  public void setStar(int star) {
    this.star = star;
  }

  public int getLevel() {
    return level;
  }

  public void setLevel(int level) {
    this.level = level;
  }

  public int getHeroAdditionId() {
    return heroAdditionId;
  }

  public void setHeroAdditionId(int heroAdditionId) {
    this.heroAdditionId = heroAdditionId;
  }

  public int getSkillId() {
    return skillId;
  }

  public void setSkillId(int skillId) {
    this.skillId = skillId;
  }

  public int getSkillValue() {
    return skillValue;
  }

  public void setSkillValue(int skillValue) {
    this.skillValue = skillValue;
  }

  public int getResolveId() {
    return resolveId;
  }

  public void setResolveId(int resolveId) {
    this.resolveId = resolveId;
  }

  public int getSoul() {
    return soul;
  }

  public void setSoul(int soul) {
    this.soul = soul;
  }

  public int getCanup() {
    return canup;
  }

  public void setCanup(int canup) {
    this.canup = canup;
  }

  public List<List<Integer>> getMeta() {
    return meta;
  }

  public void setMeta(List<List<Integer>> meta) {
    this.meta = meta;
  }

  public List<List<Integer>> getAttr() {
    return attr;
  }

  public void setAttr(List<List<Integer>> attr) {
    this.attr = attr;
  }

  public int getTankCount() {
    return tankCount;
  }

  public void setTankCount(int tankCount) {
    this.tankCount = tankCount;
  }

  public int getOrder() {
    return order;
  }

  public void setOrder(int order) {
    this.order = order;
  }

  public int getCompound() {
    return compound;
  }

  public void setCompound(int compound) {
    this.compound = compound;
  }

  public int getProbability() {
    return probability;
  }

  public void setProbability(int probability) {
    this.probability = probability;
  }

  public int getAwakenHeroId() {
    return awakenHeroId;
  }

  public void setAwakenHeroId(int awakenHeroId) {
    this.awakenHeroId = awakenHeroId;
  }

  public String getAwakenCond() {
    return awakenCond;
  }

  public void setAwakenCond(String awakenCond) {
    this.awakenCond = awakenCond;
  }

  public List<Integer> getAwakenSkillArr() {
    return awakenSkillArr;
  }

  public void setAwakenSkillArr(List<Integer> awakenSkillArr) {
    this.awakenSkillArr = awakenSkillArr;
  }

  public List<Integer> getCost1() {
    return cost1;
  }

  public void setCost1(List<Integer> cost1) {
    this.cost1 = cost1;
  }

  public int getUpProb1() {
    return upProb1;
  }

  public void setUpProb1(int upProb1) {
    this.upProb1 = upProb1;
  }

  public List<Integer> getCost2() {
    return cost2;
  }

  public void setCost2(List<Integer> cost2) {
    this.cost2 = cost2;
  }

  public int getUpProb2() {
    return upProb2;
  }

  public void setUpProb2(int upProb2) {
    this.upProb2 = upProb2;
  }

  public int getFailTimes() {
    return failTimes;
  }

  public void setFailTimes(int failTimes) {
    this.failTimes = failTimes;
  }

  public int getCommanderLv() {
    return commanderLv;
  }

  public void setCommanderLv(int commanderLv) {
    this.commanderLv = commanderLv;
  }
}
