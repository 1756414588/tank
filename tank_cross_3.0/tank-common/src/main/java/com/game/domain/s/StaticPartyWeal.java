package com.game.domain.s;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-10 下午2:02:26
 * @declare
 */
public class StaticPartyWeal {

  private int wealLv;
  private List<List<Integer>> wealList;

  public int getWealLv() {
    return wealLv;
  }

  public void setWealLv(int wealLv) {
    this.wealLv = wealLv;
  }

  public List<List<Integer>> getWealList() {
    return wealList;
  }

  public void setWealList(List<List<Integer>> wealList) {
    this.wealList = wealList;
  }
}
