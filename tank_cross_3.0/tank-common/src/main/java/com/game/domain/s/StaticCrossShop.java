package com.game.domain.s;

import java.util.List;

/**
 * @author TanDonghai @ClassName StaticCrossShop.java @Description TODO
 * @date 创建时间：2016年10月12日 上午11:52:23
 */
public class StaticCrossShop {
  private int goodID; // 商品ID

  private String goodName; // 商品名字

  private int type; // 商品类别

  private boolean treasure; // 是否是珍品 1，是；0，否。

  private int cost; // 消耗

  private int personNumber; // 个人限购次数

  private int totalNumber; // 全服限购次数,0表示无限制。

  private List<List<Integer>> rewardList; // 包含的物品

  public int getGoodID() {
    return goodID;
  }

  public void setGoodID(int goodID) {
    this.goodID = goodID;
  }

  public int getType() {
    return type;
  }

  public String getGoodName() {
    return goodName;
  }

  public void setGoodName(String goodName) {
    this.goodName = goodName;
  }

  public void setType(int type) {
    this.type = type;
  }

  public boolean isTreasure() {
    return treasure;
  }

  public void setTreasure(boolean treasure) {
    this.treasure = treasure;
  }

  public int getCost() {
    return cost;
  }

  public void setCost(int cost) {
    this.cost = cost;
  }

  public int getPersonNumber() {
    return personNumber;
  }

  public void setPersonNumber(int personNumber) {
    this.personNumber = personNumber;
  }

  public int getTotalNumber() {
    return totalNumber;
  }

  public void setTotalNumber(int totalNumber) {
    this.totalNumber = totalNumber;
  }

  public List<List<Integer>> getRewardList() {
    return rewardList;
  }

  public void setRewardList(List<List<Integer>> rewardList) {
    this.rewardList = rewardList;
  }

  @Override
  public String toString() {
    return "StaticCrossShop [goodID="
        + goodID
        + ", type="
        + type
        + ", treasure="
        + treasure
        + ", cost="
        + cost
        + ", personNumber="
        + personNumber
        + ", totalNumber="
        + totalNumber
        + ", rewardList="
        + rewardList
        + "]";
  }
}
