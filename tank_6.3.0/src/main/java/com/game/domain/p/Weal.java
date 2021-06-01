package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-4 下午3:26:02
 * @Description: 帮派成员采集资源累积
 */

public class Weal {

	private long stone;
	private long iron;
	private long silicon;
	private long copper;
	private long oil;
	private int gold;

	public long getStone() {
		return stone;
	}

	public void setStone(long stone) {
		this.stone = stone;
	}

	public long getIron() {
		return iron;
	}

	public void setIron(long iron) {
		this.iron = iron;
	}

	public long getSilicon() {
		return silicon;
	}

	public void setSilicon(long silicon) {
		this.silicon = silicon;
	}

	public long getCopper() {
		return copper;
	}

	public void setCopper(long copper) {
		this.copper = copper;
	}

	public long getOil() {
		return oil;
	}

	public void setOil(long oil) {
		this.oil = oil;
	}

	public int getGold() {
		return gold;
	}

	public void setGold(int gold) {
		this.gold = gold;
	}

	public Weal() {
	}

	public Weal(long stone, long iron, long silicon, long copper, long oil, int gold) {
		this.stone = stone;
		this.iron = iron;
		this.silicon = silicon;
		this.copper = copper;
		this.oil = oil;
		this.gold = gold;
	}

}
