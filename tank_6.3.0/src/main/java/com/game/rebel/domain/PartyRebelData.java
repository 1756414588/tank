package com.game.rebel.domain;

import com.game.constant.RebelConstant;
import com.game.pb.CommonPb;

/**
 * @author: LiFeng
 * @date:
 * @description:叛军入侵军团数据
 */
public class PartyRebelData {

	private int partyId;

	private String partyName;

	private int rank; // 军团系统的排行，用于当积分相同时的进一步排序

	private int lastRank;// 军团上周排行

	private int killUnit;// 本周军团击杀分队数量

	private int killGuard;// 本周军团击杀卫队数量

	private int killLeader;// 本周军团击杀领袖数量

	private int score;// 本周军团获得的积分

	public int getRank() {
		return rank;
	}

	public void setRank(int rank) {
		this.rank = rank;
	}

	public int getPartyId() {
		return partyId;
	}

	public void setPartyId(int partyId) {
		this.partyId = partyId;
	}

	public String getPartyName() {
		return partyName;
	}

	public void setPartyName(String partyName) {
		this.partyName = partyName;
	}

	public int getLastRank() {
		return lastRank;
	}

	public void setLastRank(int lastRank) {
		this.lastRank = lastRank;
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

	public PartyRebelData(int partyId, String partyName, int rank) {
		super();
		this.partyId = partyId;
		this.partyName = partyName;
		this.rank = rank;
	}

	public PartyRebelData() {
		super();
	}

	public PartyRebelData (CommonPb.PartyRebelData data) {
		this.partyId = data.getPartyId();
		this.partyName = data.getPartyName();
		this.rank = data.getRank();
		this.lastRank = data.getLastRank();
		this.killUnit = data.getKillUnit();
		this.killGuard = data.getKillGuard();
		this.killLeader = data.getKillLeader();
		this.score = data.getScore();
	}
	
	/**
	 * 记录军团的杀人数，并记录得分
	 * 
	 * @param type
	 * @return
	 */
	public void addKillNum(int type) {
		if (type == RebelConstant.REBEL_TYPE_UNIT) {
			killUnit++;
			score += RebelConstant.REBEL_SCORE_UNIT;
		} else if (type == RebelConstant.REBEL_TYPE_GUARD) {
			killGuard++;
			score += RebelConstant.REBEL_SCORE_GUARD;
		} else {
			killLeader++;
			score += RebelConstant.REBEL_SCORE_LEADER;
		}
	}

	/**
	 * 重写这两个方法是为了在计算参加过叛军活动的军团时（根据玩家数据计算） 达到去重复的效果
	 * 
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + partyId;
		result = prime * result + ((partyName == null) ? 0 : partyName.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		PartyRebelData other = (PartyRebelData) obj;
		if (partyId != other.partyId)
			return false;
		if (partyName == null) {
			if (other.partyName != null)
				return false;
		} else if (!partyName.equals(other.partyName))
			return false;
		return true;
	}

}
