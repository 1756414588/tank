package com.game.domain.s;

/**
 * @author ChenKui
 * @version 创建时间：2015-12-7 下午3:24:01
 * @declare 签到（30天以后）
 */

public class StaticSignLogin {

	private int loginId;
	private int grid;
	private int type;
	private int itemId;
	private int count;
	private int probability;

	public int getLoginId() {
		return loginId;
	}

	public void setLoginId(int loginId) {
		this.loginId = loginId;
	}

	public int getGrid() {
		return grid;
	}

	public void setGrid(int grid) {
		this.grid = grid;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getItemId() {
		return itemId;
	}

	public void setItemId(int itemId) {
		this.itemId = itemId;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public int getProbability() {
		return probability;
	}

	public void setProbability(int probability) {
		this.probability = probability;
	}

}
