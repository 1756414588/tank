package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 描述
 * @created 2017/12/20 10:01
 */
public class StaticLaboratoryMilitary {

  private int kid;
  private int skillId;
  private int type;
  private int lv;
  private int obj;
  private List<List<Integer>> cost;
  private List<List<Integer>> effect;
  private int tankId;
  private List<List<Integer>> perSkill;
  private String desc;
  private String icon;

  public int getKid() {
    return kid;
  }

  public void setKid(int kid) {
    this.kid = kid;
  }

  public int getSkillId() {
    return skillId;
  }

  public void setSkillId(int skillId) {
    this.skillId = skillId;
  }

  public int getTankId() {
    return tankId;
  }

  public void setTankId(int tankId) {
    this.tankId = tankId;
  }

  public String getDesc() {
    return desc;
  }

  public void setDesc(String desc) {
    this.desc = desc;
  }

  public String getIcon() {
    return icon;
  }

  public void setIcon(String icon) {
    this.icon = icon;
  }

  public List<List<Integer>> getCost() {
    return cost;
  }

  public void setCost(List<List<Integer>> cost) {
    this.cost = cost;
  }

  public List<List<Integer>> getEffect() {
    return effect;
  }

  public void setEffect(List<List<Integer>> effect) {
    this.effect = effect;
  }

  public List<List<Integer>> getPerSkill() {
    return perSkill;
  }

  public void setPerSkill(List<List<Integer>> perSkill) {
    this.perSkill = perSkill;
  }

  public int getLv() {
    return lv;
  }

  public void setLv(int lv) {
    this.lv = lv;
  }

  public int getType() {
    return type;
  }

  public void setType(int type) {
    this.type = type;
  }

  public int getObj() {
    return obj;
  }

  public void setObj(int obj) {
    this.obj = obj;
  }
}
