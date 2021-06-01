package com.game.domain.s;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2015-10-29 下午5:26:47
 * @declare
 */
public class StaticActGeneral {

  private int generalId;
  private int activityId;
  private int heroId;
  private int repeat;
  private int count;
  private int price;
  private int point;
  private List<List<Integer>> awardList;
  private String desc;

  public int getGeneralId() {
    return generalId;
  }

  public void setGeneralId(int generalId) {
    this.generalId = generalId;
  }

  public int getActivityId() {
    return activityId;
  }

  public void setActivityId(int activityId) {
    this.activityId = activityId;
  }

  public int getHeroId() {
    return heroId;
  }

  public void setHeroId(int heroId) {
    this.heroId = heroId;
  }

  public int getRepeat() {
    return repeat;
  }

  public void setRepeat(int repeat) {
    this.repeat = repeat;
  }

  public int getCount() {
    return count;
  }

  public void setCount(int count) {
    this.count = count;
  }

  public int getPrice() {
    return price;
  }

  public void setPrice(int price) {
    this.price = price;
  }

  public int getPoint() {
    return point;
  }

  public void setPoint(int point) {
    this.point = point;
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
}
