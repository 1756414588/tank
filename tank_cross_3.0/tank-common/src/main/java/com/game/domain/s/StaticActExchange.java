package com.game.domain.s;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2016-02-17 上午11:17:36
 * @declare 活动奖励
 */
public class StaticActExchange {

  private int exchangeId;
  private int activityId;
  private int formulaId;
  private int limit;
  private int free;
  private int price;
  private int metaCount;
  private List<List<Integer>> meta1;
  private List<List<Integer>> meta2;
  private List<List<Integer>> meta3;
  private List<List<Integer>> meta4;
  private List<List<Integer>> meta5;
  private List<List<Integer>> metas;
  private List<List<Integer>> awardList;

  public int getExchangeId() {
    return exchangeId;
  }

  public void setExchangeId(int exchangeId) {
    this.exchangeId = exchangeId;
  }

  public int getActivityId() {
    return activityId;
  }

  public void setActivityId(int activityId) {
    this.activityId = activityId;
  }

  public int getFormulaId() {
    return formulaId;
  }

  public void setFormulaId(int formulaId) {
    this.formulaId = formulaId;
  }

  public int getLimit() {
    return limit;
  }

  public void setLimit(int limit) {
    this.limit = limit;
  }

  public int getFree() {
    return free;
  }

  public void setFree(int free) {
    this.free = free;
  }

  public int getPrice() {
    return price;
  }

  public void setPrice(int price) {
    this.price = price;
  }

  public int getMetaCount() {
    return metaCount;
  }

  public void setMetaCount(int metaCount) {
    this.metaCount = metaCount;
  }

  public List<List<Integer>> getMetas() {
    return metas;
  }

  public void setMetas(List<List<Integer>> metas) {
    this.metas = metas;
  }

  public List<List<Integer>> getAwardList() {
    return awardList;
  }

  public List<List<Integer>> getMeta1() {
    return meta1;
  }

  public void setMeta1(List<List<Integer>> meta1) {
    this.meta1 = meta1;
  }

  public List<List<Integer>> getMeta2() {
    return meta2;
  }

  public void setMeta2(List<List<Integer>> meta2) {
    this.meta2 = meta2;
  }

  public List<List<Integer>> getMeta3() {
    return meta3;
  }

  public void setMeta3(List<List<Integer>> meta3) {
    this.meta3 = meta3;
  }

  public List<List<Integer>> getMeta4() {
    return meta4;
  }

  public void setMeta4(List<List<Integer>> meta4) {
    this.meta4 = meta4;
  }

  public List<List<Integer>> getMeta5() {
    return meta5;
  }

  public void setMeta5(List<List<Integer>> meta5) {
    this.meta5 = meta5;
  }

  public void setAwardList(List<List<Integer>> awardList) {
    this.awardList = awardList;
  }
}
