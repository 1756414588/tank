package com.game.domain.s.tactics;

import java.util.List;

public class StaticTacticsTacticsRestrict {
  //
  //    CREATE TABLE `s_tactics _tacticsRestrict` (
  //            `Id` int(11) NOT NULL COMMENT 'id',
  //            `tacticsType1` int(11) NOT NULL COMMENT '当前战术套编号',
  //            `tacticsType2` int(11) NOT NULL COMMENT '克制的战术套编号',
  //            `attrUp` int(11) NOT NULL COMMENT '克制时，装配的战术提高的属性提高n/100',
  //    PRIMARY KEY (`Id`)
  // ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
  private int Id;
  private int tacticsType1;
  private int tacticsType2;
  private int attrUp;
  private List<List<Integer>> attrSuit;

  public int getId() {
    return Id;
  }

  public void setId(int id) {
    Id = id;
  }

  public int getTacticsType1() {
    return tacticsType1;
  }

  public void setTacticsType1(int tacticsType1) {
    this.tacticsType1 = tacticsType1;
  }

  public int getTacticsType2() {
    return tacticsType2;
  }

  public void setTacticsType2(int tacticsType2) {
    this.tacticsType2 = tacticsType2;
  }

  public int getAttrUp() {
    return attrUp;
  }

  public void setAttrUp(int attrUp) {
    this.attrUp = attrUp;
  }

  public List<List<Integer>> getAttrSuit() {
    return attrSuit;
  }

  public void setAttrSuit(List<List<Integer>> attrSuit) {
    this.attrSuit = attrSuit;
  }
}
