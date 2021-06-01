package com.game.honour.domain;

/**
 * @author: LiFeng
 * @date:
 * @description: 荣耀玩法玩家个人积分
 */
public class HonourRoleScore implements Comparable<HonourRoleScore> {

	private long roleId;

	private int openTime;

	private int score;

	private int rankTime; // 上榜时间(并不是第一次进入排行榜的时间，而是进入排行榜后达到某个分数的时间)

	private int partyId; // 最好一次获得积分时的所在军团，变更方案后没使用到这个属性，但保留

	public int getPartyId() {
		return partyId;
	}

	public void setPartyId(int partyId) {
		this.partyId = partyId;
	}

	public long getRoleId() {
		return roleId;
	}

	public void setRoleId(long roleId) {
		this.roleId = roleId;
	}

	public int getOpenTime() {
		return openTime;
	}

	public void setOpenTime(int openTime) {
		this.openTime = openTime;
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

	public HonourRoleScore(long roleId, int openTime) {
		super();
		this.roleId = roleId;
		this.openTime = openTime;
	}

	public HonourRoleScore() {
		super();
	}

	public HonourRoleScore(com.game.pb.CommonPb.HonourScore honourRoleScore) {
		this.roleId = honourRoleScore.getRoleId();
		this.openTime = honourRoleScore.getOpenTime();
		this.score = honourRoleScore.getScore();
		this.rankTime = honourRoleScore.getRankTime();
		this.partyId = honourRoleScore.getPartyId();
	}

	public com.game.pb.CommonPb.HonourScore toPb() {
		com.game.pb.CommonPb.HonourScore.Builder builder = com.game.pb.CommonPb.HonourScore.newBuilder();
		builder.setOpenTime(openTime);
		builder.setRankTime(rankTime);
		builder.setRoleId(roleId);
		builder.setScore(score);
		builder.setPartyId(partyId);
		return builder.build();
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + openTime;
		result = prime * result + (int) (roleId ^ (roleId >>> 32));
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
		HonourRoleScore other = (HonourRoleScore) obj;
		if (openTime != other.openTime)
			return false;
		if (roleId != other.roleId)
			return false;
		return true;
	}

	@Override
	public int compareTo(HonourRoleScore obj) {
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
