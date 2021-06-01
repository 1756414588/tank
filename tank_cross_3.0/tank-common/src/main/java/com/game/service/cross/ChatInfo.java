package com.game.service.cross;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/13 11:33
 * @description：
 */
public class ChatInfo {

  private int day;
  private String beginTime;
  private String endTime;
  private int id;

  public String getBeginTime() {
    return beginTime;
  }

  public void setBeginTime(String beginTime) {
    this.beginTime = beginTime;
  }

  public String getEndTime() {
    return endTime;
  }

  public void setEndTime(String endTime) {
    this.endTime = endTime;
  }

  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public int getDay() {
    return day;
  }

  public void setDay(int day) {
    this.day = day;
  }

  public ChatInfo(int day, String beginTime, String endTime, int id) {
    super();
    this.day = day;
    this.beginTime = beginTime;
    this.endTime = endTime;
    this.id = id;
  }
}
