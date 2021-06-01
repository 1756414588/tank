package com.game.domain.s;

import java.util.List;

/**
 * @author: LiFeng
 * @date: 4.19
 * @description: 赏金活动商店
 */
public class StaticBountyShop {

	private int goodId;
	private List<Integer> reward;
	private int cost;
	private int personNumber;
	private int openWeek;

	public int getOpenWeek() {
		return openWeek;
	}

	public void setOpenWeek(int openWeek) {
		this.openWeek = openWeek;
	}

	public int getGoodId() {
		return goodId;
	}

	public void setGoodId(int goodId) {
		this.goodId = goodId;
	}

	public List<Integer> getReward() {
		return reward;
	}

	public void setReward(List<Integer> reward) {
		this.reward = reward;
	}

	public int getCost() {
		return cost;
	}

	public void setCost(int cost) {
		this.cost = cost;
	}

	public int getPersonNumber() {
		return personNumber;
	}

	public void setPersonNumber(int personNumber) {
		this.personNumber = personNumber;
	}

}
