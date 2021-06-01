package com.game.domain.s;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2015-12-12 下午3:47:02
 * @declare
 */
public class StaticActRaffle {
  private int raffleId;
  private int activityId;
  private int price;
  private int tenPrice;
  private int lockPrice;
  private int lockTenPrice;
  private int scale;
  private int probability;
  private List<Integer> tankList;
  private int count;

  public int getRaffleId() {
    return raffleId;
  }

  public void setRaffleId(int raffleId) {
    this.raffleId = raffleId;
  }

  public int getActivityId() {
    return activityId;
  }

  public void setActivityId(int activityId) {
    this.activityId = activityId;
  }

  public int getPrice() {
    return price;
  }

  public void setPrice(int price) {
    this.price = price;
  }

  public int getTenPrice() {
    return tenPrice;
  }

  public void setTenPrice(int tenPrice) {
    this.tenPrice = tenPrice;
  }

  public int getLockPrice() {
    return lockPrice;
  }

  public void setLockPrice(int lockPrice) {
    this.lockPrice = lockPrice;
  }

  public int getLockTenPrice() {
    return lockTenPrice;
  }

  public void setLockTenPrice(int lockTenPrice) {
    this.lockTenPrice = lockTenPrice;
  }

  public int getScale() {
    return scale;
  }

  public void setScale(int scale) {
    this.scale = scale;
  }

  public int getProbability() {
    return probability;
  }

  public void setProbability(int probability) {
    this.probability = probability;
  }

  public List<Integer> getTankList() {
    return tankList;
  }

  public void setTankList(List<Integer> tankList) {
    this.tankList = tankList;
  }

  public int getCount() {
    return count;
  }

  public void setCount(int count) {
    this.count = count;
  }
}
