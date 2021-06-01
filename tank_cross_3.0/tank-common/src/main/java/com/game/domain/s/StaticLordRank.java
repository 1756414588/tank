/**
 * @Title: StaticLordRank.java @Package com.game.domain.s @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年9月3日 下午5:15:21
 * @version V1.0
 */
package com.game.domain.s;

/**
 * @ClassName: StaticLordRank @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年9月3日 下午5:15:21
 */
public class StaticLordRank {
  private int rankId;
  private String name;
  private int lordLv;
  private long stoneCost;
  private int fame;

  public int getRankId() {
    return rankId;
  }

  public void setRankId(int rankId) {
    this.rankId = rankId;
  }

  public int getLordLv() {
    return lordLv;
  }

  public void setLordLv(int lordLv) {
    this.lordLv = lordLv;
  }

  public long getStoneCost() {
    return stoneCost;
  }

  public void setStoneCost(long stoneCost) {
    this.stoneCost = stoneCost;
  }

  public int getFame() {
    return fame;
  }

  public void setFame(int fame) {
    this.fame = fame;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }
}
