package com.game.domain.p;

import com.game.pb.CommonPb;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class ActLuckyPoolLog {

	private String name; // 玩家昵称
	private int time; // 中奖时间
	private String goodInfo; // 物品信息

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getTime() {
		return time;
	}

	public void setTime(int time) {
		this.time = time;
	}

	public String getGoodInfo() {
		return goodInfo;
	}

	public void setGoodInfo(String goodName) {
		this.goodInfo = goodName;
	}
	
	public ActLuckyPoolLog(CommonPb.ActLuckyPoolLog log) {
		this.name = log.getName();
		this.time = log.getTime();
		this.goodInfo = log.getGoodInfo();
	}

	public ActLuckyPoolLog() {
		super();
	}
	
	
}
