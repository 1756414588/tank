package com.game.domain.s;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2015-10-24 下午3:17:36
 * @declare 活动奖励
 */
public class StaticActAward {

  private int keyId;
  private int activityId;
  private int sortId;
  private int cond;
  private List<List<Integer>> awardList;
  private String desc;
  private String param;

  public int getKeyId() {
    return keyId;
  }

  public void setKeyId(int keyId) {
    this.keyId = keyId;
  }

  public int getActivityId() {
    return activityId;
  }

  public void setActivityId(int activityId) {
    this.activityId = activityId;
  }

  public int getSortId() {
    return sortId;
  }

  public void setSortId(int sortId) {
    this.sortId = sortId;
  }

  public int getCond() {
    return cond;
  }

  public void setCond(int cond) {
    this.cond = cond;
  }

  public List<List<Integer>> getAwardList() {
    return awardList;
  }

  public void setAwardList(List<List<Integer>> awardList) {
    this.awardList = awardList;
  }

  public String getDesc() {
    return desc;
  }

  public void setDesc(String desc) {
    this.desc = desc;
  }

  public String getParam() {
    return param;
  }

  public void setParam(String param) {
    this.param = param;
  }
}
