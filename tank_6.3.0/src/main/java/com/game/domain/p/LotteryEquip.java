package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-8 上午10:50:58
* @Description: 抽装备
 */

public class LotteryEquip {
	private int lotteryId;
	private int freetimes;
	private int cd;
	// private int lotteryTime;
	private int purple;
	private int time;

	public int getLotteryId() {
		return lotteryId;
	}

	public void setLotteryId(int lotteryId) {
		this.lotteryId = lotteryId;
	}

	public int getFreetimes() {
		return freetimes;
	}

	public void setFreetimes(int freetimes) {
		this.freetimes = freetimes;
	}

	public int getCd() {
		return cd;
	}

	public void setCd(int cd) {
		this.cd = cd;
	}

	// public int getLotteryTime() {
	// return lotteryTime;
	// }
	//
	// public void setLotteryTime(int lotteryTime) {
	// this.lotteryTime = lotteryTime;
	// }

	public int getPurple() {
		return purple;
	}

	public void setPurple(int purple) {
		this.purple = purple;
	}

	public int getTime() {
		return time;
	}

	public void setTime(int time) {
		this.time = time;
	}

}
