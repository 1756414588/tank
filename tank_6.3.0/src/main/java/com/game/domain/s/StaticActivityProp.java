package com.game.domain.s;

import java.util.List;
/**
* @ClassName: StaticActivityProp 
* @Description: 活动道具表
* @author
 */
public class StaticActivityProp {
	private int id; // 活动道具id
	private int activityId; // 所属活动id
	private List<Integer> kind; // 合成需要哪些道具
	private List<List<Integer>> change; // 活动结束 自动兑换奖励
	private int canbuy;
	private int price;
	private int value; // 对应值
	private List<List<Integer>> awards;  //  使用获得奖励
	private List<List<Integer>> trapezoidalprice;//梯形价格的活动道具，用数组配置，[≤次数,价格]

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

	public List<Integer> getKind() {
		return kind;
	}

	public void setKind(List<Integer> kind) {
		this.kind = kind;
	}

	public List<List<Integer>> getChange() {
		return change;
	}

	public void setChange(List<List<Integer>> change) {
		this.change = change;
	}

	public int getCanbuy() {
		return canbuy;
	}

	public void setCanbuy(int canbuy) {
		this.canbuy = canbuy;
	}

	public int getPrice() {
		return price;
	}

	public void setPrice(int price) {
		this.price = price;
	}

	public int getValue() {
		return value;
	}

	public void setValue(int value) {
		this.value = value;
	}

	public List<List<Integer>> getAwards() {
		return awards;
	}

	public void setAwards(List<List<Integer>> awards) {
		this.awards = awards;
	}

	public List<List<Integer>> getTrapezoidalprice() {
		return trapezoidalprice;
	}

	public void setTrapezoidalprice(List<List<Integer>> trapezoidalprice) {
		this.trapezoidalprice = trapezoidalprice;
	}

}
