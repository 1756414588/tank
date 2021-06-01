package com.game.domain.s.tactics;

import java.util.List;

public class StaticTacticsTankSuit {

  //    CREATE TABLE `s_tactics _tankSuit` (
  //            `Id` int(11) NOT NULL COMMENT 'id',
  //            `quality` int(11) NOT NULL COMMENT '兵种套品质，品质向下兼容（如5个紫色，1个蓝色，则是蓝色兵种套效果）',
  //            `tankType` int(11) NOT NULL COMMENT '兵种套类型，1-战车，2-坦克，3-火炮，4-火箭，5-全部',
  //            `effectTank` int(11) NOT NULL COMMENT '兵种套属性使用的兵种类型，1-战车，2-坦克，3-火炮，4-火箭，5-全部',
  //            `attrUp` varchar(255) NOT NULL COMMENT '兵种套提供的属性',
  //            `attrRestrict` int(11) NOT NULL COMMENT '兵种套提高的兵种克制额外加成，n/100',
  //    PRIMARY KEY (`Id`)
  // ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  private int Id;
  private int quality;
  private int tacticsType;
  private int tankType;
  private int effectTank;
  private List<List<Integer>> attrUp;
  private int attrRestrict;

  public int getId() {
    return Id;
  }

  public void setId(int id) {
    Id = id;
  }

  public int getQuality() {
    return quality;
  }

  public void setQuality(int quality) {
    this.quality = quality;
  }

  public int getTankType() {
    return tankType;
  }

  public void setTankType(int tankType) {
    this.tankType = tankType;
  }

  public int getEffectTank() {
    return effectTank;
  }

  public void setEffectTank(int effectTank) {
    this.effectTank = effectTank;
  }

  public List<List<Integer>> getAttrUp() {
    return attrUp;
  }

  public void setAttrUp(List<List<Integer>> attrUp) {
    this.attrUp = attrUp;
  }

  public int getAttrRestrict() {
    return attrRestrict;
  }

  public void setAttrRestrict(int attrRestrict) {
    this.attrRestrict = attrRestrict;
  }

  public int getTacticsType() {
    return tacticsType;
  }

  public void setTacticsType(int tacticsType) {
    this.tacticsType = tacticsType;
  }
}
