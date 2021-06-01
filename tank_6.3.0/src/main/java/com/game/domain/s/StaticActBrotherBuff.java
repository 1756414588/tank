package com.game.domain.s;

import java.util.List;

/**
 * @ClassName:StaticActBrotherBuff
 * @author zc
 * @Description:对应s_act_brother_buff表
 * @date 2017年9月11日
 */
public class StaticActBrotherBuff {
	private int id;// 编号
	private int level;// buff等级
	private int type;
	private List<List<Integer>> effcetVal;// buff值
	private int price;// 升级价格

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public List<List<Integer>> getEffcetVal() {
		return effcetVal;
	}

	public void setEffcetVal(List<List<Integer>> effcetVal) {
		this.effcetVal = effcetVal;
	}

	public int getPrice() {
		return price;
	}

	public void setPrice(int price) {
		this.price = price;
	}
}
