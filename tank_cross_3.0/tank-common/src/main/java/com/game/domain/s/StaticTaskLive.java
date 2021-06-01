package com.game.domain.s;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-24 下午3:35:11
 * @declare
 */
public class StaticTaskLive {

  private int id;
  private int live;
  private List<List<Integer>> awardList;

  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public int getLive() {
    return live;
  }

  public void setLive(int live) {
    this.live = live;
  }

  public List<List<Integer>> getAwardList() {
    return awardList;
  }

  public void setAwardList(List<List<Integer>> awardList) {
    this.awardList = awardList;
  }
}
