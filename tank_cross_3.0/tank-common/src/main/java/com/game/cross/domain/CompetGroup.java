package com.game.cross.domain;

import java.util.HashMap;
import java.util.Map;

/**
 * 比赛的组
 *
 * @author wanyi
 */
public class CompetGroup {
  private int competGroupId;
  private ComptePojo c1;
  private ComptePojo c2;
  private int win = -1; // -1.未战斗 0.失败 1.胜利,2平局

  public Map<Integer, CompteRound> map = new HashMap<Integer, CompteRound>();

  public int getWin() {
    return win;
  }

  public void setWin(int win) {
    this.win = win;
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

  public void setC1(ComptePojo c1) {
    this.c1 = c1;
  }

  public ComptePojo getC2() {
    return c2;
  }

  public void setC2(ComptePojo c2) {
    this.c2 = c2;
  }

  public Map<Integer, CompteRound> getMap() {
    return map;
  }

  public void setMap(Map<Integer, CompteRound> map) {
    this.map = map;
  }

  @Override
  public String toString() {
    return "CompetGroup [competGroupId="
        + competGroupId
        + ", c1="
        + c1
        + ", c2="
        + c2
        + ", win="
        + win
        + ", map="
        + map
        + "]";
  }
}
