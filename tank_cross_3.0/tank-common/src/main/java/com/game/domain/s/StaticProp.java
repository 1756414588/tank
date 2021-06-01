/**
 * @Title: StaticProp.java @Package com.game.domain.s @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月13日 下午4:31:28
 * @version V1.0
 */
package com.game.domain.s;

import java.util.List;

/**
 * @ClassName: StaticProp @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月13日 下午4:31:28
 */
public class StaticProp {
  private int propId;
  private String propName;
  private int tag;
  private int color;
  private int price;
  private int canBuy;
  private int canBuild;
  private int canUse;
  private int arenaScore;
  private int stoneCost;
  private int skillBook;
  private int heroChip;
  private int buildTime;
  private int effectType;
  private List<List<Integer>> effectValue;

  public int getPropId() {
    return propId;
  }

  public void setPropId(int propId) {
    this.propId = propId;
  }

  public int getPrice() {
    return price;
  }

  public void setPrice(int price) {
    this.price = price;
  }

  public int getEffectType() {
    return effectType;
  }

  public void setEffectType(int effectType) {
    this.effectType = effectType;
  }

  public List<List<Integer>> getEffectValue() {
    return effectValue;
  }

  public void setEffectValue(List<List<Integer>> effectValue) {
    this.effectValue = effectValue;
  }

  public int getTag() {
    return tag;
  }

  public void setTag(int tag) {
    this.tag = tag;
  }

  public int getColor() {
    return color;
  }

  public void setColor(int color) {
    this.color = color;
  }

  public int getCanBuy() {
    return canBuy;
  }

  public void setCanBuy(int canBuy) {
    this.canBuy = canBuy;
  }

  public int getCanBuild() {
    return canBuild;
  }

  public void setCanBuild(int canBuild) {
    this.canBuild = canBuild;
  }

  public int getStoneCost() {
    return stoneCost;
  }

  public void setStoneCost(int stoneCost) {
    this.stoneCost = stoneCost;
  }

  public int getSkillBook() {
    return skillBook;
  }

  public void setSkillBook(int skillBook) {
    this.skillBook = skillBook;
  }

  public int getHeroChip() {
    return heroChip;
  }

  public void setHeroChip(int heroChip) {
    this.heroChip = heroChip;
  }

  public int getBuildTime() {
    return buildTime;
  }

  public void setBuildTime(int buildTime) {
    this.buildTime = buildTime;
  }

  public int getCanUse() {
    return canUse;
  }

  public void setCanUse(int canUse) {
    this.canUse = canUse;
  }

  public int getArenaScore() {
    return arenaScore;
  }

  public void setArenaScore(int arenaScore) {
    this.arenaScore = arenaScore;
  }

  public String getPropName() {
    return propName;
  }

  public void setPropName(String propName) {
    this.propName = propName;
  }
}
