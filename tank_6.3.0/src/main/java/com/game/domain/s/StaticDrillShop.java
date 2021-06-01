package com.game.domain.s;

import java.util.List;

/**
 * @ClassName StaticDrillShop.java
 * @Description 对应s_redblue_shop表 红蓝大战商店
 * @author TanDonghai
 * @date 创建时间：2016年8月11日 下午7:18:59
 *
 */
public class StaticDrillShop {
	private int goodID;// 商品ID

	private int type;// 商品类别

	private boolean treasure;// 是否是珍品 1，是；0，否。

	private int cost;// 消耗

	private int personNumber;// 个人限购次数

	private int totalNumber;// 全服限购次数,0表示无限制。

	private List<Integer> rewardList;// 包含的物品

	public int getGoodID() {
		return goodID;
	}

	public void setGoodID(int goodID) {
		this.goodID = goodID;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public boolean isTreasure() {
		return treasure;
	}

	public void setTreasure(boolean treasure) {
		this.treasure = treasure;
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

	public int getTotalNumber() {
		return totalNumber;
	}

	public void setTotalNumber(int totalNumber) {
		this.totalNumber = totalNumber;
	}

	public List<Integer> getRewardList() {
		return rewardList;
	}

	public void setRewardList(List<Integer> rewardList) {
		this.rewardList = rewardList;
	}

	@Override
	public String toString() {
		return "StaticDrillShop [goodID=" + goodID + ", type=" + type + ", treasure=" + treasure + ", cost=" + cost
				+ ", personNumber=" + personNumber + ", totalNumber=" + totalNumber + ", rewardList=" + rewardList
				+ "]";
	}
}
