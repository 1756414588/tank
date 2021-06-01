package com.game.domain.p;

import java.util.ArrayList;
import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2015-11-18 下午2:36:27
 * @Description:  活动军团排行榜
 */

public class ActPartyRank {
	private int Rank;
	private int partyId;
	private int rankType;
	private long rankValue;
	private String param;
	private List<Long> lordIds = new ArrayList<Long>();
	private long rankTime;// 上榜时间，毫秒数

	public int getRank() {
		return Rank;
	}

	public void setRank(int rank) {
		Rank = rank;
	}

	public int getPartyId() {
		return partyId;
	}

	public void setPartyId(int partyId) {
		this.partyId = partyId;
	}

	public int getRankType() {
		return rankType;
	}

	public void setRankType(int rankType) {
		this.rankType = rankType;
	}

	public long getRankValue() {
		return rankValue;
	}

	public void setRankValue(long rankValue) {
		this.rankValue = rankValue;
	}

	public String getParam() {
		return param;
	}

	public void setParam(String param) {
		this.param = param;
	}

	public List<Long> getLordIds() {
		return lordIds;
	}

	public void setLordIds(List<Long> lordIds) {
		this.lordIds = lordIds;
	}

	public long getRankTime() {
		return rankTime;
	}

	public void setRankTime(long rankTime) {
		this.rankTime = rankTime;
	}

	public ActPartyRank() {
	}

	public ActPartyRank(int partyId, int type, long value) {
		this.partyId = partyId;
		this.rankType = type;
		this.rankValue = value;
		this.rankTime = System.currentTimeMillis();
	}

	public ActPartyRank(int partyId, int type, long value, long rankTime) {
		this.partyId = partyId;
		this.rankType = type;
		this.rankValue = value;
		this.rankTime = rankTime;
	}
}
