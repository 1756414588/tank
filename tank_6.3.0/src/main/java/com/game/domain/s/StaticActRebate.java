package com.game.domain.s;

import java.util.List;

import com.game.util.RandomHelper;

/**
 * @author ChenKui
 * @version 创建时间：2015-10-24 下午3:17:36
 * @declare 节日返利
 */

public class StaticActRebate {

	private int rebateId;
	private int type;
	private int activityId;
	private int money;
	private List<List<Integer>> probability;
	private String desc;

	public int getRebateId() {
		return rebateId;
	}

	public void setRebateId(int rebateId) {
		this.rebateId = rebateId;
	}
	
	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getActivityId() {
		return activityId;
	}

	public void setActivityId(int activityId) {
		this.activityId = activityId;
	}

	public int getMoney() {
		return money;
	}

	public void setMoney(int money) {
		this.money = money;
	}

	public List<List<Integer>> getProbability() {
		return probability;
	}

	public void setProbability(List<List<Integer>> probability) {
		this.probability = probability;
	}

	public String getDesc() {
		return desc;
	}

	public void setDesc(String desc) {
		this.desc = desc;
	}

	public int getRandomRebate() {
		List<List<Integer>> llist = this.probability;
		int total = 0;
		for (List<Integer> e : llist) {
			if (e.size() != 2) {
				continue;
			}
			total += e.get(1);
		}
		total = RandomHelper.randomInSize(total);
		int index = 0;
		for (List<Integer> e : llist) {
			if (e.size() != 2) {
				continue;
			}
			index += e.get(1);
			if (total <= index) {
				return e.get(0);
			}
		}
		return 0;
	}
}
