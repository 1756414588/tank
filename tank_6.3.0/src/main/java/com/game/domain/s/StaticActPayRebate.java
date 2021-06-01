package com.game.domain.s;

/**
 * 返利我做主概率表
 */
public class StaticActPayRebate {
	
	private int weight;  // 转盘权重
	private int value;   // 转盘值
	private int type;    // 类型  1.返利百分率    2.充值金额

	public int getWeight() {
		return weight;
	}

	public void setWeight(int weight) {
		this.weight = weight;
	}

	public int getValue() {
		return value;
	}

	public void setValue(int value) {
		this.value = value;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}
	
}
