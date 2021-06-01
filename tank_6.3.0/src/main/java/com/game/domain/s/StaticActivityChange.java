package com.game.domain.s;

import java.util.List;

/**
* @ClassName: StaticActivityChange 
* @Description: 活到道具兑换表
* @author
 */
public class StaticActivityChange {

	private int id;
	private int activityId;                  // 活动id
	private List<List<Integer>> award;     // 奖励
	private int itemNum;                     // 兑换次数  -1为无限兑换
	private List<List<Integer>> more;        // 兑换所需道具

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getActivityId() {
		return activityId;
	}

	public void setActivityId(int activityId) {
		this.activityId = activityId;
	}

	public List<List<Integer>> getAward() {
		return award;
	}

	public void setAwardId(List<List<Integer>> award) {
		this.award = award;
	}

	public int getItemNum() {
		return itemNum;
	}

	public void setItemNum(int itemNum) {
		this.itemNum = itemNum;
	}

	public List<List<Integer>> getMore() {
		return more;
	}

	public void setMore(List<List<Integer>> more) {
		this.more = more;
	}

}
