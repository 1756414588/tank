package com.game.domain.s;

import java.util.List;

/**
 * @author zhangdh @ClassName: StaticMilitaryRank @Description: 官职
 * @date 2017-05-26 11:24
 */
public class StaticMilitaryRank {
  private int id;
  private int lordLv;
  private long mpltLimit;
  private List<List<Integer>> upCost;
  private List<List<Integer>> attrs;

  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public int getLordLv() {
    return lordLv;
  }

  public void setLordLv(int lordLv) {
    this.lordLv = lordLv;
  }

  public List<List<Integer>> getUpCost() {
    return upCost;
  }

  public void setUpCost(List<List<Integer>> upCost) {
    this.upCost = upCost;
  }

  public List<List<Integer>> getAttrs() {
    return attrs;
  }

  public void setAttrs(List<List<Integer>> attrs) {
    this.attrs = attrs;
  }

  public long getMpltLimit() {
    return mpltLimit;
  }

  public void setMpltLimit(long mpltLimit) {
    this.mpltLimit = mpltLimit;
  }
}
