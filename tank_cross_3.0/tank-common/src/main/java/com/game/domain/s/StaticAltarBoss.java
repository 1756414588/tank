package com.game.domain.s;

import java.util.ArrayList;
import java.util.List;

/**
 * @author TanDonghai @ClassName StaticAltarBoss.java @Description 祭坛BOSS相关信息
 * @date 创建时间：2016年7月15日 上午11:05:26
 */
public class StaticAltarBoss {
  private int lv; // 祭坛或祭坛BOSS等级
  private int callBossCost; // 该等级祭坛召唤BOSS需要消耗的建设度
  private int callBossCD; // 该等级祭坛召唤BOSS的冷却时间，单位：秒
  private int fightTime; // 该等级祭坛击杀BOSS的时间，单位：秒
  private String bossName; // 该等级BOSS的名称
  private List<List<Integer>> partAward; // 该等级BOSS的参与奖励
  private List<List<Integer>> killAward; // BOSS的最后一击奖励
  private List<List<Integer>> rankAward1; // BOSS的排行奖励，第1名
  private List<List<Integer>> rankAward2; // BOSS的排行奖励，第2名
  private List<List<Integer>> rankAward3; // BOSS的排行奖励，第3名

  private List<List<Integer>> halfPartAward; // 仅驻内存变量，记录参与奖励减半后的奖励

  public int getLv() {
    return lv;
  }

  public void setLv(int lv) {
    this.lv = lv;
  }

  public int getCallBossCost() {
    return callBossCost;
  }

  public void setCallBossCost(int callBossCost) {
    this.callBossCost = callBossCost;
  }

  public int getCallBossCD() {
    return callBossCD;
  }

  public void setCallBossCD(int callBossCD) {
    this.callBossCD = callBossCD;
  }

  public int getFightTime() {
    return fightTime;
  }

  public void setFightTime(int fightTime) {
    this.fightTime = fightTime;
  }

  public String getBossName() {
    return bossName;
  }

  public void setBossName(String bossName) {
    this.bossName = bossName;
  }

  public List<List<Integer>> getPartAward() {
    return partAward;
  }

  public void setPartAward(List<List<Integer>> partAward) {
    this.partAward = partAward;
  }

  public List<List<Integer>> getKillAward() {
    return killAward;
  }

  public void setKillAward(List<List<Integer>> killAward) {
    this.killAward = killAward;
  }

  public List<List<Integer>> getRankAward1() {
    return rankAward1;
  }

  public void setRankAward1(List<List<Integer>> rankAward1) {
    this.rankAward1 = rankAward1;
  }

  public List<List<Integer>> getRankAward2() {
    return rankAward2;
  }

  public void setRankAward2(List<List<Integer>> rankAward2) {
    this.rankAward2 = rankAward2;
  }

  public List<List<Integer>> getRankAward3() {
    return rankAward3;
  }

  public void setRankAward3(List<List<Integer>> rankAward3) {
    this.rankAward3 = rankAward3;
  }

  /**
   * 获取减半后的参与奖励
   *
   * @return
   */
  public List<List<Integer>> getHalfPartAward() {
    if (null == halfPartAward) {
      Integer awardNum = null;
      halfPartAward = new ArrayList<List<Integer>>();
      for (List<Integer> list : partAward) {
        List<Integer> halfList = new ArrayList<Integer>();
        halfList.addAll(list);
        awardNum = halfList.get(halfList.size() - 1);
        if (null != awardNum) {
          halfList.set(halfList.size() - 1, (awardNum + 1) / 2); // 向上取整
        }
        halfPartAward.add(halfList);
      }
    }

    return halfPartAward;
  }

  @Override
  public String toString() {
    return "StaticAltarBoss [lv="
        + lv
        + ", callBossCost="
        + callBossCost
        + ", callBossCD="
        + callBossCD
        + ", fightTime="
        + fightTime
        + ", bossName="
        + bossName
        + ", partAward="
        + partAward
        + ", killAward="
        + killAward
        + ", rankAward1="
        + rankAward1
        + ", rankAward2="
        + rankAward2
        + ", rankAward3="
        + rankAward3
        + "]";
  }
}
