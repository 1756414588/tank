package com.game.rebel.domain;

/**
 * @ClassName RebelRank.java
 * @Description 叛军击杀排名信息
 * @author TanDonghai
 * @date 创建时间：2016年9月5日 上午11:35:25
 *
 */
public class RebelRank {
	private int rank; // 排行
	private long lordId; // lordId
	private String name; // 玩家名称
	private int killUnit; // 玩家击杀分队数量
	private int killGuard; // 玩家击杀卫队数量
	private int killLeader; // 玩家击杀领袖数量
	private int score; // 玩家的积分

	public int getRank() {
		return rank;
	}

	public void setRank(int rank) {
		this.rank = rank;
	}

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
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

	@Override
	public String toString() {
		return "RebelRank [rank=" + rank + ", lordId=" + lordId + ", name=" + name + ", killUnit=" + killUnit
				+ ", killGuard=" + killGuard + ", killLeader=" + killLeader + ", score=" + score + "]";
	}
}
