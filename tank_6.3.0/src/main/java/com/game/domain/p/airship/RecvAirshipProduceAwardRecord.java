package com.game.domain.p.airship;

/**
 * @ClassName:RecvAirshipProduceAwardRecord
 * @author zc
 * @Description: 玩家征收飞艇生产物品的记录
 * @date 2017年8月12日
 */
public class RecvAirshipProduceAwardRecord {
	private int timeSec;       //征收时间（秒）
	private long lordId;       //征收玩家id
	private int type;          //类型
	private int awardId;       //征收物品id
	private int count;         //征收数量
	private int mplt;          //消耗军功
	
	public int getTimeSec() {
		return timeSec;
	}
	public void setTimeSec(int timeSec) {
		this.timeSec = timeSec;
	}
	public long getLordId() {
		return lordId;
	}
	public void setLordId(long lordId) {
		this.lordId = lordId;
	}
	public int getType() {
		return type;
	}
	public void setType(int type) {
		this.type = type;
	}
	public int getAwardId() {
		return awardId;
	}
	public void setAwardId(int awardId) {
		this.awardId = awardId;
	}
	public int getCount() {
		return count;
	}
	public void setCount(int count) {
		this.count = count;
	}
	public int getMplt() {
		return mplt;
	}
	public void setMplt(int mplt) {
		this.mplt = mplt;
	}
	
}
