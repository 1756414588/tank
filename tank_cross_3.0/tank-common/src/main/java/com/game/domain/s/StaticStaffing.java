/**
 * @Title: StaticStaffing.java @Package com.game.domain.s @Description: TODO
 *
 * @author ZhangJun
 * @date 2016年3月10日 下午6:23:42
 * @version V1.0
 */
package com.game.domain.s;

import java.util.List;

/**
 * @ClassName: StaticStaffing @Description: TODO
 *
 * @author ZhangJun
 * @date 2016年3月10日 下午6:23:42
 */
public class StaticStaffing {
  private int staffingId;
  private String name;
  private int rank;
  private int staffingLv;
  private int countLimit;
  private List<List<Integer>> attr;

  public int getStaffingId() {
    return staffingId;
  }

  public void setStaffingId(int staffingId) {
    this.staffingId = staffingId;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public int getRank() {
    return rank;
  }

  public void setRank(int rank) {
    this.rank = rank;
  }

  public int getStaffingLv() {
    return staffingLv;
  }

  public void setStaffingLv(int staffingLv) {
    this.staffingLv = staffingLv;
  }

  public int getCountLimit() {
    return countLimit;
  }

  public void setCountLimit(int countLimit) {
    this.countLimit = countLimit;
  }

  public List<List<Integer>> getAttr() {
    return attr;
  }

  public void setAttr(List<List<Integer>> attr) {
    this.attr = attr;
  }
}
