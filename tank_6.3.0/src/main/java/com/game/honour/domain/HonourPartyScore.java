package com.game.honour.domain;

/**
 * @author: LiFeng
 * @date:
 * @description: 荣耀玩法军团积分
 */
public class HonourPartyScore implements Comparable<HonourPartyScore> {

	private int partyId;

	private int openTime;

	private int score;

	private int rankTime; // 上榜时间

	public int getPartyId() {
		return partyId;
	}

	public void setPartyId(int partyId) {
		this.partyId = partyId;
	}

	public int getScore() {
		return score;
	}

	public void setScore(int score) {
		this.score = score;
	}

	public int getRankTime() {
		return rankTime;
	}

	public void setRankTime(int rankTime) {
		this.rankTime = rankTime;
	}

	public int getOpenTime() {
		return openTime;
	}

	public void setOpenTime(int openTime) {
		this.openTime = openTime;
	}

	public HonourPartyScore(int partyId, int openTime) {
		super();
		this.partyId = partyId;
		this.openTime = openTime;
	}

	public HonourPartyScore(com.game.pb.CommonPb.HonourScore partyScore) {
		this.partyId = partyScore.getPartyId();
		this.openTime = partyScore.getOpenTime();
		this.rankTime = partyScore.getRankTime();
		this.score = partyScore.getScore();
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + openTime;
		result = prime * result + partyId;
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
		HonourPartyScore other = (HonourPartyScore) obj;
		if (openTime != other.openTime)
			return false;
		if (partyId != other.partyId)
			return false;
		return true;
	}

	@Override
	public int compareTo(HonourPartyScore obj) {
		if (this.getScore() > obj.getScore()) {
			return -1;
		} else if (this.getScore() < obj.getScore()) {
			return 1;
		} else {
			if (this.getRankTime() != 0) {
				if (this.getRankTime() < obj.getRankTime()) {
					return -1;
				} else if (this.getRankTime() > obj.getRankTime()) {
					return 1;
				}
			} else {
				return 1;
			}
		}
		return 0;
	}

}
