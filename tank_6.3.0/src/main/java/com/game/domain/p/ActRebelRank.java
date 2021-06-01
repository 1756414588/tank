package com.game.domain.p;

import com.game.pb.SerializePb;

/**
* @ClassName: ActRebelRank 
* @Description: 活动叛军排行
* @author
 */
public class ActRebelRank {
	private long lordId;
	private int killNum;// 击杀数
	private int score;// 积分
	private int lastUpdateTime;// 玩家最后一次参加叛军活动的活动开启时间

	public ActRebelRank(long lordId) {
		this.lordId = lordId;
	}
	
	public ActRebelRank(SerializePb.SerActRebelRank sarr){
		this.lordId = sarr.getLordId();
		this.killNum = sarr.getKillNum();
		this.score = sarr.getScore();
		this.lastUpdateTime = sarr.getLastUpdateTime();
	}

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public int getKillNum() {
		return killNum;
	}

	public void setKillNum(int killNum) {
		this.killNum = killNum;
	}

	public int getScore() {
		return score;
	}

	public void setScore(int score) {
		this.score = score;
	}

	public int getLastUpdateTime() {
		return lastUpdateTime;
	}

	public void setLastUpdateTime(int lastUpdateTime) {
		this.lastUpdateTime = lastUpdateTime;
	}

}
