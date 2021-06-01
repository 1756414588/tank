package com.game.domain.s;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-1 上午10:52:08
 * @declare 英雄招募消耗配置
 */

public class StaticCost {

	private int costId;
	private int count;
	private int type;
	private int price;

	public int getCostId() {
		return costId;
	}

	public void setCostId(int costId) {
		this.costId = costId;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getPrice() {
		return price;
	}

	public void setPrice(int price) {
		this.price = price;
	}

}
