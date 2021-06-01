package com.game.rebel.domain;

import com.game.constant.RebelConstant;

/**
 * @ClassName RoleRebelData.java
 * @Description 玩家在叛军活动中的信息记录
 * @author TanDonghai
 * @date 创建时间：2016年9月5日 上午11:07:25
 *
 */
public class RoleRebelData {
	private long lordId;

	private String nick;// 角色名称

	private int lastUpdateWeek;// 玩家最后一次参加叛军活动是在开服第几周

	private int lastUpdateTime;// 玩家最后一次参加叛军活动的活动开启时间

	private int lastRank;// 玩家上周排行

	private int killNum;// 今日击杀数

	private int killUnit;// 本周玩家击杀分队数量

	private int killGuard;// 本周玩家击杀卫队数量

	private int killLeader;// 本周玩家击杀领袖数量 110
	
//	private int killLeader11;// 本周玩家击杀领袖数量10
//
//	private boolean =true;
	
	private int score;// 本周玩家获得的积分

	private int totalUnit;// 玩家击杀分队叛军总数

	private int totalGuard;// 玩家击杀卫队叛军总数

	private int totalLeader;// 玩家击杀领袖叛军总数

	private int totalScore;// 玩家总积分
	
	private int weekRankTime;// 玩家进入周排行榜的时间
	
	private int totalRankTime;// 玩家进入总排行榜的时间

	public RoleRebelData() {

	}

	public RoleRebelData(com.game.pb.CommonPb.RoleRebelData data) {
		setLordId(data.getLordId());
		setNick(data.getName());
		setLastUpdateWeek(data.getLastUpdateWeek());
		setLastUpdateTime(data.getLastUpdateTime());
		setKillNum(data.getKillNum());
		setKillUnit(data.getKillUnit());
		setKillGuard(data.getKillGuard());
		setKillLeader(data.getKillLeader());
		setScore(data.getScore());
		setTotalUnit(data.getTotalUnit());
		setTotalGuard(data.getTotalGuard());
		setTotalLeader(data.getTotalLeader());
		setTotalScore(data.getTotalScore());
		setWeekRankTime(data.getWeekRankTime());
		setTotalRankTime(data.getTotalRankTime());
	}

	/**
	 * 重置本周击杀数和得分
	 * 
	 * @param lastUpdateWeek
	 */
	public void cleanWeekData(int lastUpdateWeek) {
		killNum = 0;
		killUnit = 0;
		killGuard = 0;
		killLeader = 0;
		score = 0;
		if(lastUpdateWeek > 0) {
			this.lastUpdateWeek = lastUpdateWeek;
		}
	}

	/**
	 * 记录玩家的杀人数，并记录得分
	 * 
	 * @param type
	 * @return
	 */
	public int addKillNum(int type) {
		if (type == RebelConstant.REBEL_TYPE_UNIT) {
			killUnit++;
			totalUnit++;
			score += RebelConstant.REBEL_SCORE_UNIT;
			totalScore += RebelConstant.REBEL_SCORE_UNIT;
		} else if (type == RebelConstant.REBEL_TYPE_GUARD) {
			killGuard++;
			totalGuard++;
			score += RebelConstant.REBEL_SCORE_GUARD;
			totalScore += RebelConstant.REBEL_SCORE_GUARD;
		} else {
			killLeader++;
			totalLeader++;
			score += RebelConstant.REBEL_SCORE_LEADER;
			totalScore += RebelConstant.REBEL_SCORE_LEADER;
		}
		killNum++;
		return killNum;
	}

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public String getNick() {
		return nick;
	}

	public void setNick(String nick) {
		this.nick = nick;
	}

	public int getLastUpdateWeek() {
		return lastUpdateWeek;
	}

	public void setLastUpdateWeek(int lastUpdateWeek) {
		this.lastUpdateWeek = lastUpdateWeek;
	}

	public int getLastUpdateTime() {
		return lastUpdateTime;
	}

	public void setLastUpdateTime(int lastUpdateTime) {
		this.lastUpdateTime = lastUpdateTime;
	}

	public int getLastRank() {
		return lastRank;
	}

	public void setLastRank(int lastRank) {
		this.lastRank = lastRank;
	}

	public int getKillNum() {
		return killNum;
	}

	public void setKillNum(int killNum) {
		this.killNum = killNum;
	}

	public int getKillUnit() {
		return killUnit;
	}

	public void setKillUnit(int killUnit) {
		this.killUnit = killUnit;
	}

	public int getKillGuard() {
		return killGuard;
	}

	public void setKillGuard(int killGuard) {
		this.killGuard = killGuard;
	}

	public int getKillLeader() {
		return killLeader;
	}

	public void setKillLeader(int killLeader) {
		this.killLeader = killLeader;
	}

	public int getScore() {
		return score;
	}

	public void setScore(int score) {
		this.score = score;
	}

	public int getTotalUnit() {
		return totalUnit;
	}

	public void setTotalUnit(int totalUnit) {
		this.totalUnit = totalUnit;
	}

	public int getTotalGuard() {
		return totalGuard;
	}

	public void setTotalGuard(int totalGuard) {
		this.totalGuard = totalGuard;
	}

	public int getTotalLeader() {
		return totalLeader;
	}

	public void setTotalLeader(int totalLeader) {
		this.totalLeader = totalLeader;
	}

	public int getTotalScore() {
		return totalScore;
	}

	public void setTotalScore(int totalScore) {
		this.totalScore = totalScore;
	}

	public int getWeekRankTime() {
		return weekRankTime;
	}

	public void setWeekRankTime(int weekRankTime) {
		this.weekRankTime = weekRankTime;
	}

	public int getTotalRankTime() {
		return totalRankTime;
	}

	public void setTotalRankTime(int totalRankTime) {
		this.totalRankTime = totalRankTime;
	}

	@Override
	public String toString() {
		return "RoleRebelData [lordId=" + lordId + ", nick=" + nick + ", lastUpdateWeek=" + lastUpdateWeek
				+ ", lastUpdateTime=" + lastUpdateTime + ", lastRank=" + lastRank + ", killNum=" + killNum
				+ ", killUnit=" + killUnit + ", killGuard=" + killGuard + ", killLeader=" + killLeader + ", score="
				+ score + ", totalUnit=" + totalUnit + ", totalGuard=" + totalGuard + ", totalLeader=" + totalLeader
				+ ", totalScore=" + totalScore + ", weekRankTime=" + weekRankTime + ", totalRankTime=" + totalRankTime
				+ "]";
	}
}
