package com.game.domain;

public class CrossSysMailInfo {
  private int dayNum; // 第几天
  private String dayTime = ""; // 几点

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

  @Override
  public String toString() {
    return dayNum + "_" + dayTime;
  }
}
