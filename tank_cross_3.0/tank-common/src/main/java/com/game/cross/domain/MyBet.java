package com.game.cross.domain;

import java.util.ArrayList;
import java.util.List;

public class MyBet {
  private int myGroup; // 1精英组 2巅峰组
  private int stage; // 1淘汰赛,2总决赛
  private int groupType; // 淘汰赛有分组,1A 2B 3C 4D
  private int competGroupId; // 淘汰赛(1-15组) 总决赛(1-4组)
  private ComptePojo c1;
  private ComptePojo c2;
  private int win = -2; // -1.未战斗 0.失败 1.胜利 定义默认值为-2
  private List<CompteRound> compteRounds = new ArrayList<CompteRound>();
  private int betState; // 1已经领取,2点击领取，3 还未结束
  private long betTime; // 下注时间(秒)

  public int getStage() {
    return stage;
  }

  public void setStage(int stage) {
    this.stage = stage;
  }

  public int getGroupType() {
    return groupType;
  }

  public void setGroupType(int groupType) {
    this.groupType = groupType;
  }

  public int getCompetGroupId() {
    return competGroupId;
  }

  public void setCompetGroupId(int competGroupId) {
    this.competGroupId = competGroupId;
  }

  public ComptePojo getC1() {
    return c1;
  }

  public int getMyGroup() {
    return myGroup;
  }

  public void setMyGroup(int myGroup) {
    this.myGroup = myGroup;
  }

  public void setC1(ComptePojo c1) {
    this.c1 = c1;
  }

  public ComptePojo getC2() {
    return c2;
  }

  public void setC2(ComptePojo c2) {
    this.c2 = c2;
  }

  public int getWin() {
    return win;
  }

  public void setWin(int win) {
    this.win = win;
  }

  public List<CompteRound> getCompteRounds() {
    return compteRounds;
  }

  public void setCompteRounds(List<CompteRound> compteRounds) {
    this.compteRounds = compteRounds;
  }

  public int getBetState() {
    return betState;
  }

  public void setBetState(int betState) {
    this.betState = betState;
  }

  public long getBetTime() {
    return betTime;
  }

  public void setBetTime(long betTime) {
    this.betTime = betTime;
  }
}
