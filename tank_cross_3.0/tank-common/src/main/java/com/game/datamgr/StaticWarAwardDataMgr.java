package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticWarAward;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class StaticWarAwardDataMgr extends BaseDataMgr {
  @Autowired private StaticDataDao staticDataDao;

  private Map<Integer, StaticWarAward> awardMap = new HashMap<Integer, StaticWarAward>();

  /**
   * Overriding: init
   *
   */
  @Override
  public void init() {
    Map<Integer, StaticWarAward> awardMap = staticDataDao.selectWarAward();
    this.awardMap = awardMap;
  }

  public List<List<Integer>> getRankAward(int rank) {
    return awardMap.get(rank).getRankAwards();
  }

  public List<List<Integer>> getWinAward(int rank) {
    return awardMap.get(rank).getWinAwards();
  }

  public List<List<Integer>> getHurtAward(int rank) {
    return awardMap.get(rank).getHurtAwards();
  }

  public List<List<Integer>> getScoreAward(int rank) {
    return awardMap.get(rank).getScoreAwards();
  }

  public List<List<Integer>> getScorePartyAward(int rank) {
    return awardMap.get(rank).getScorePartyAwards();
  }

  public List<List<Integer>> getFortressRankAward(int rank) {
    return awardMap.get(rank).getFortressRankAward();
  }

  public List<List<Integer>> getDrillRankAward(int rank) {
    return awardMap.get(rank).getDrillRankAward();
  }

  public List<List<Integer>> getDrillPartWinAward() {
    return awardMap.get(1).getDrillPartWinAward();
  }

  public List<List<Integer>> getDrillPartFailAward() {
    return awardMap.get(1).getDrillPartFailAward();
  }

  public List<List<Integer>> getRebelRankReward(int rank) {
    return awardMap.get(rank).getRebelRankAward();
  }

  public List<List<Integer>> getRebelBuffReward() {
    return awardMap.get(1).getRebelBuffAward();
  }

  // 跨服精英赛全服奖励
  public List<List<Integer>> getEliteAllAwards(int rank) {
    return awardMap.get(rank).getEliteAllAwards();
  }

  // 跨服精英赛排名奖励
  public List<List<Integer>> getEliteServerRankAwards(int rank) {
    return awardMap.get(rank).getEliteServerRankAwards();
  }

  // '跨服巅峰组排名奖
  public List<List<Integer>> getTopServerRankAwards(int rank) {
    return awardMap.get(rank).getTopServerRankAwards();
  }

  // 跨服巅峰组全服奖励
  public List<List<Integer>> getTopAllAwards(int rank) {
    return awardMap.get(rank).getTopAllAwards();
  }

  // '跨服军团争霸军团排行',
  public List<List<Integer>> getServerPartyRankAward(int rank) {
    return awardMap.get(rank).getServerPartyRankAward();
  }

  // 跨服军团争霸个人排行',
  public List<List<Integer>> getServerPartyPersonAward(int rank) {
    return awardMap.get(rank).getServerPartyPersonAward();
  }

  // '跨服军团争霸连胜排行
  public List<List<Integer>> getServerPartyWinAward(int rank) {
    return awardMap.get(rank).getServerPartyWinAward();
  }

  // '跨服军团争霸全服奖励',
  public List<List<Integer>> getServerPartyAllAward(int rank) {
    return awardMap.get(rank).getServerPartyAllAward();
  }
}
