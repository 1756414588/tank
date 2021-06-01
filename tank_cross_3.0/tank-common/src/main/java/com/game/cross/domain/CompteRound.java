package com.game.cross.domain;

/**
 * 比赛回合
 *
 * @author wanyi
 */
public class CompteRound {
  private int roundNum;

  private int win;

  private int reportKey;

  private int detail;

  private int whoFist; // 1进攻方先手。 2防守方先手。 0没有战斗

  private int attackDestroyNum; // 进攻方损失坦克
  private int DenfenceDestroyNum; // 防守方损失坦克

  public int getWhoFist() {
    return whoFist;
  }

  public void setWhoFist(int whoFist) {
    this.whoFist = whoFist;
  }

  public int getAttackDestroyNum() {
    return attackDestroyNum;
  }

  public void setAttackDestroyNum(int attackDestroyNum) {
    this.attackDestroyNum = attackDestroyNum;
  }

  public int getDenfenceDestroyNum() {
    return DenfenceDestroyNum;
  }

  public void setDenfenceDestroyNum(int denfenceDestroyNum) {
    DenfenceDestroyNum = denfenceDestroyNum;
  }

  public int getRoundNum() {
    return roundNum;
  }

  public void setRoundNum(int roundNum) {
    this.roundNum = roundNum;
  }

  public int getWin() {
    return win;
  }

  public void setWin(int win) {
    this.win = win;
  }

  public int getReportKey() {
    return reportKey;
  }

  public void setReportKey(int reportKey) {
    this.reportKey = reportKey;
  }

  public int getDetail() {
    return detail;
  }

  public void setDetail(int detail) {
    this.detail = detail;
  }

  public CompteRound() {
    super();
  }

  public CompteRound(int roundNum, int win, int reportKey, int detail) {
    super();
    this.roundNum = roundNum;
    this.win = win;
    this.reportKey = reportKey;
    this.detail = detail;
  }
}
