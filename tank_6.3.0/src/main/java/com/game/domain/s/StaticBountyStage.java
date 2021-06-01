package com.game.domain.s;

import java.util.List;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class StaticBountyStage {

	private int id;
	private String name;
	private int award;
	private List<List<Integer>> reward;
	private int count;
	private int wave;
	private int showBoss;
	private List<Integer> openTime;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getAward() {
		return award;
	}

	public void setAward(int award) {
		this.award = award;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public int getWave() {
		return wave;
	}

	public void setWave(int wave) {
		this.wave = wave;
	}

	public int getShowBoss() {
		return showBoss;
	}

	public void setShowBoss(int showBoss) {
		this.showBoss = showBoss;
	}

	public List<Integer> getOpenTime() {
		return openTime;
	}

	public void setOpenTime(List<Integer> openTime) {
		this.openTime = openTime;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public List<List<Integer>> getReward() {
		return reward;
	}

	public void setReward(List<List<Integer>> reward) {
		this.reward = reward;
	}


}
