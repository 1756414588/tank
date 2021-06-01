package com.game.domain.p;

import java.util.HashMap;
import java.util.Map;

/**
 * @author: LiFeng
 * @date:
 * @description:转盘类活动，当天活动信息记录（会每天清除）
 */
public class DialDailyGoalInfo {

	private int lastDay;	// 最后一次抽取是在哪天
	private int count;		// 当日抽奖次数
	// key:awardId  value:-1不可领取，0可领取，1已领取
	private Map<Integer, Integer> rewardStatus = new HashMap<>();

	public int getLastDay() {
		return lastDay;
	}

	public void setLastDay(int lastDay) {
		this.lastDay = lastDay;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public Map<Integer, Integer> getRewardStatus() {
		return rewardStatus;
	}

	public void setRewardStatus(Map<Integer, Integer> rewardStatus) {
		this.rewardStatus = rewardStatus;
	}
	
}
