package com.game.domain.s;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2015-11-2 下午5:26:20
 * @declare
 */
public class StaticActQuota {

  private int quotaId;
  private int activityId;
  private List<List<Integer>> awardList;
  private int display;
  private int price;
  private int count;
  private int cond;
  private String desc;

  public int getQuotaId() {
    return quotaId;
  }

  public void setQuotaId(int quotaId) {
    this.quotaId = quotaId;
  }

  public int getActivityId() {
    return activityId;
  }

  public void setActivityId(int activityId) {
    this.activityId = activityId;
  }

  public List<List<Integer>> getAwardList() {
    return awardList;
  }

  public void setAwardList(List<List<Integer>> awardList) {
    this.awardList = awardList;
  }

  public int getDisplay() {
    return display;
  }

  public void setDisplay(int display) {
    this.display = display;
  }

  public int getPrice() {
    return price;
  }

  public void setPrice(int price) {
    this.price = price;
  }

  public int getCount() {
    return count;
  }

  public void setCount(int count) {
    this.count = count;
  }

  public int getCond() {
    return cond;
  }

  public void setCond(int cond) {
    this.cond = cond;
  }

  public String getDesc() {
    return desc;
  }

  public void setDesc(String desc) {
    this.desc = desc;
  }
}
