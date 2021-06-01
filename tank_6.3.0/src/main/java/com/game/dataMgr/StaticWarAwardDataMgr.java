package com.game.dataMgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticDay7Act;
import com.game.domain.s.StaticWarAward;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
* @ClassName: StaticWarAwardDataMgr 
* @Description: 各种排行奖励配置
* @author
 */
@Component
public class StaticWarAwardDataMgr extends BaseDataMgr {
	@Autowired
	private StaticDataDao staticDataDao;

	private Map<Integer, StaticWarAward> awardMap = new HashMap<Integer, StaticWarAward>();
	
	private Map<Integer, List<StaticDay7Act>> day7ActList = new HashMap<Integer, List<StaticDay7Act>>();
	
	private Map<Integer, StaticDay7Act> day7ActMap = new HashMap<Integer, StaticDay7Act>();
	
	private Map<Integer, List<StaticDay7Act>> day7ActTypeList = new TreeMap<Integer, List<StaticDay7Act>>();

	/**
	 * Overriding: init
	 * 
	 * @see com.game.dataMgr.BaseDataMgr#init()
	 */
	@Override
	public void init() {
		Map<Integer, StaticWarAward> awardMap = staticDataDao.selectWarAward();
		this.awardMap = awardMap;
		initActDayTask();
	}
	
	/**
	 * 
	* @Title: initActDayTask 
	* @Description:   7日活动奖励配置

	 */
	private void initActDayTask() {
		List<StaticDay7Act> list = staticDataDao.selectStaticDay7ActList();
		
		Map<Integer, List<StaticDay7Act>> day7ActList = new TreeMap<Integer, List<StaticDay7Act>>();
	    Map<Integer, StaticDay7Act> day7ActMap = new TreeMap<Integer, StaticDay7Act>();
		Map<Integer, List<StaticDay7Act>> day7ActTypeList = new TreeMap<Integer, List<StaticDay7Act>>();
	    
		for (StaticDay7Act e : list) {
			List<StaticDay7Act> dayList = day7ActList.get(e.getDay());
			if(dayList == null){
				dayList = new ArrayList<>();
				day7ActList.put(e.getDay(),dayList);
			}
			dayList.add(e);
			day7ActMap.put(e.getKeyId(), e);
			List<StaticDay7Act> typeList = day7ActTypeList.get(e.getType());
			if(typeList == null){
				typeList = new ArrayList<>();
				day7ActTypeList.put(e.getType(), typeList);
			}
			typeList.add(e);
		}
		
		this.day7ActList = day7ActList;
		this.day7ActMap = day7ActMap;
		this.day7ActTypeList = day7ActTypeList;
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
	
	public List<List<Integer>> getRebelPartyRankReward(int rank) {
		return awardMap.get(rank).getRebelPartyRankAward();
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
		StaticWarAward config = awardMap.get(rank);
		if( config == null ){
			LogUtil.error("跨服战奖励为null rank="+rank);
			return new ArrayList<>();
		}
		return config.getServerPartyPersonAward();
	}

	// '跨服军团争霸连胜排行
	public List<List<Integer>> getServerPartyWinAward(int rank) {
		return awardMap.get(rank).getServerPartyWinAward();
	}

	// '跨服军团争霸全服奖励',
	public List<List<Integer>> getServerPartyAllAward(int rank) {
		return awardMap.get(rank).getServerPartyAllAward();
	}

	public List<StaticDay7Act> getDay7ActList(int day) {
		return day7ActList.get(day);
	}

	public StaticDay7Act getDay7Act(int keyId) {
		return day7ActMap.get(keyId);
	}

	public List<StaticDay7Act> getDay7ActTypeList(int type) {
		return day7ActTypeList.get(type);
	}
	
	public List<List<Integer>> getHonourLiveRankReward(int rank) {
		return awardMap.get(rank).getHonourLiveRankAward();
	}
	
	public List<List<Integer>> getHonourLivePartyRankReward(int rank) {
		return awardMap.get(rank).getHonourLivePartyRankAward();
	}

	/**
	 * 获取跨服军矿个人奖励
	 * @param rank
	 * @return
	 */
	public List<List<Integer>> getCrossMineAward(int rank){
		return awardMap.get(rank).getServerMineRankAward();
	}

	/**
	 * 获取跨服军矿服务器奖励
	 * @param rank
	 * @return
	 */
	public List<List<Integer>> getCrossServerMineAward(int rank){
		return awardMap.get(rank).getServerMinePartyRankAward();
	}


}
