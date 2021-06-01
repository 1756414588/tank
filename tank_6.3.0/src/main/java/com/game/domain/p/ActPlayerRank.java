package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2015-11-25 下午3:03:08
 * @Description:  活动玩家排行榜
 */

public class ActPlayerRank {
	private int rank;   //排名值
	private long lordId;// 玩家ID
	private int rankType;// 组别
	private long rankValue;// 实际数据值
	private String param;// 参数
	private long rankTime;// 上榜时间，毫秒数

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

	public long getRankTime() {
		return rankTime;
	}

	public void setRankTime(long rankTime) {
		this.rankTime = rankTime;
	}

	public ActPlayerRank() {
	}

	public ActPlayerRank(long lordId, int type, long value, long rankTime) {
		this.lordId = lordId;
		this.rankType = type;
		this.rankValue = value;
		this.rankTime = rankTime;
	}

    @Override
    public String toString() {
        return "ActPlayerRank{" +
                "rank=" + rank +
                ", lordId=" + lordId +
                ", rankType=" + rankType +
                ", rankValue=" + rankValue +
                ", param='" + param + '\'' +
                ", rankTime=" + rankTime +
                '}';
    }
}
