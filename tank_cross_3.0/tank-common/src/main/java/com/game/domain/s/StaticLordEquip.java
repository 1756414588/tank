package com.game.domain.s;

import java.util.List;

/**
 * @author zhangdh @ClassName: StaticLordEquip @Description: 指挥官装备定义
 * @date 2017/4/21 14:17
 */
public class StaticLordEquip {
  private int id;
  private int pos;
  private int quality;
  private int level;
  private int formula;
  private List<List<Integer>> atts;

  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public int getPos() {
    return pos;
  }

  public void setPos(int pos) {
    this.pos = pos;
  }

  public int getQuality() {
    return quality;
  }

  public void setQuality(int quality) {
    this.quality = quality;
  }

  public int getLevel() {
    return level;
  }

  public void setLevel(int level) {
    this.level = level;
  }

  public int getFormula() {
    return formula;
  }

  public void setFormula(int formula) {
    this.formula = formula;
  }

  public List<List<Integer>> getAtts() {
    return atts;
  }

  public void setAtts(List<List<Integer>> atts) {
    this.atts = atts;
  }
}
