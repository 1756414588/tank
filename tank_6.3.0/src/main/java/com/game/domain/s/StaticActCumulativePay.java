package com.game.domain.s;

import java.util.List;

/**
 * @ClassName:StaticActCumulativePay
 * @author zc
 * @Description:能量灌注配置表
 * @date 2017年7月7日
 */
public class StaticActCumulativePay {
	private int id;
	private int activityid;// 活动编号
	private int dayid;// 活动的第几天
	private int daypay;// 每天充多少金币才达标
	private List<List<Integer>> dayawards;// 每天充值达标的奖励
	private int cumulativeint;// 需要累计充值多少天才能领大奖

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getActivityid() {
		return activityid;
	}

	public void setActivityid(int activityid) {
		this.activityid = activityid;
	}

	public int getDayid() {
		return dayid;
	}

	public void setDayid(int dayid) {
		this.dayid = dayid;
	}

	public int getDaypay() {
		return daypay;
	}

	public void setDaypay(int daypay) {
		this.daypay = daypay;
	}

	public List<List<Integer>> getDayawards() {
		return dayawards;
	}

	public void setDayawards(List<List<Integer>> dayawards) {
		this.dayawards = dayawards;
	}

	public int getCumulativeint() {
		return cumulativeint;
	}

	public void setCumulativeint(int cumulativeint) {
		this.cumulativeint = cumulativeint;
	}
}
