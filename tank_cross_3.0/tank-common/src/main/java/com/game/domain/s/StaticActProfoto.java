package com.game.domain.s;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2015-12-14 上午5:23:23
 * @declare
 */
public class StaticActProfoto {
  private int profotoId;
  private int activityId;
  private int part1;
  private int part2;
  private int part3;
  private int part4;
  private int precious;
  private int trust;

  private List<List<Integer>> dropList;

  public int getProfotoId() {
    return profotoId;
  }

  public void setProfotoId(int profotoId) {
    this.profotoId = profotoId;
  }

  public int getActivityId() {
    return activityId;
  }

  public void setActivityId(int activityId) {
    this.activityId = activityId;
  }

  public int getPart1() {
    return part1;
  }

  public void setPart1(int part1) {
    this.part1 = part1;
  }

  public int getPart2() {
    return part2;
  }

  public void setPart2(int part2) {
    this.part2 = part2;
  }

  public int getPart3() {
    return part3;
  }

  public void setPart3(int part3) {
    this.part3 = part3;
  }

  public int getPart4() {
    return part4;
  }

  public void setPart4(int part4) {
    this.part4 = part4;
  }

  public int getPrecious() {
    return precious;
  }

  public void setPrecious(int precious) {
    this.precious = precious;
  }

  public int getTrust() {
    return trust;
  }

  public void setTrust(int trust) {
    this.trust = trust;
  }

  public List<List<Integer>> getDropList() {
    return dropList;
  }

  public void setDropList(List<List<Integer>> dropList) {
    this.dropList = dropList;
  }
}
