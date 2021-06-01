package com.game.domain.s;

import java.util.List;
/**
* @ClassName: StaticActivityEffect 
* @Description: 活动祝福表
* @author
 */
public class StaticActivityEffect {
	private int activityId;// 活动ID
	private int day;// 活动开启的第几天
	private List<Integer> effectId;// 当天开启哪些effect

	public int getActivityId() {
		return activityId;
	}

	public void setActivityId(int activityId) {
		this.activityId = activityId;
	}

	public int getDay() {
		return day;
	}

	public void setDay(int day) {
		this.day = day;
	}

	public List<Integer> getEffectId() {
		return effectId;
	}

	public void setEffectId(List<Integer> effectId) {
		this.effectId = effectId;
	}

}
