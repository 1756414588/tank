package com.game.drill.domain;

/**
 * @ClassName DrillRank.java
 * @Description 红蓝大战排名
 * @author TanDonghai
 * @date 创建时间：2016年8月9日 下午2:15:37
 *
 */
public class DrillRank {
	private int rank; // 排名
	private long lordId;
	private String name; // 玩家名称
	private long fightNum; // 玩家战力
	private int successNum; // 玩家胜利次数
	private int failNum; // 玩家失败次数
	private boolean camp; // 玩家所属阵营，true为红方
	private boolean isReward;// 是否已经领取奖励

	public DrillRank() {
	}
	
	public DrillRank(com.game.pb.CommonPb.DrillRank rank) {
		this.rank = rank.getRank();
		this.lordId = rank.getLordId();
		this.name = rank.getName();
		this.fightNum = rank.getFightNum();
		this.successNum = rank.getSuccessNum();
		this.failNum = rank.getFailNum();
		this.camp = rank.getCamp();
		this.isReward = rank.getIsReward();
	}
	
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

	public long getFightNum() {
		return fightNum;
	}

	public void setFightNum(long fightNum) {
		this.fightNum = fightNum;
	}

	public int getSuccessNum() {
		return successNum;
	}

	public void setSuccessNum(int successNum) {
		this.successNum = successNum;
	}

	public int getFailNum() {
		return failNum;
	}

	public void setFailNum(int failNum) {
		this.failNum = failNum;
	}

	public boolean isCamp() {
		return camp;
	}

	public void setCamp(boolean camp) {
		this.camp = camp;
	}

	public boolean isReward() {
		return isReward;
	}

	public void setReward(boolean isReward) {
		this.isReward = isReward;
	}

	@Override
	public String toString() {
		return "DrillRank [rank=" + rank + ", lordId=" + lordId + ", name=" + name + ", fightNum=" + fightNum
				+ ", successNum=" + successNum + ", failNum=" + failNum + ", camp=" + camp + ", isReward=" + isReward
				+ "]";
	}
}
