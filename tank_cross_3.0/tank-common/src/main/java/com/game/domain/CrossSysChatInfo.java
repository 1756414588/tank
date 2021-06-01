package com.game.domain;

public class CrossSysChatInfo {
  /** 第几天 */
  private int dayNum;
  /** 几点 */
  private String dayTime = "";

  public int getDayNum() {
    return dayNum;
  }

  public void setDayNum(int dayNum) {
    this.dayNum = dayNum;
  }

  public String getDayTime() {
    return dayTime;
  }

  public void setDayTime(String dayTime) {
    this.dayTime = dayTime;
  }
}
