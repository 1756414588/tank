package com.game.domain.s;

import java.util.List;

/**
 * @ClassName StaticTreasureShop.java
 * @Description 荒宝碎片兑换商店配置类
 * @author TanDonghai
 * @date 创建时间：2016年8月3日 下午4:17:20
 *
 */
public class StaticTreasureShop {
	private int treasureId;// id
	private String treasureName;// 物品的名称
	private int openWeek;// 服务器开启之后的第几周，商店开启贩卖
	private int cost;// 购买该物品所需的荒宝碎片数量
	private int maxNumber;// 可被兑换的次数
	private List<Integer> reward;// 物品奖励信息，格式:[5,149,1]

	public int getTreasureId() {
		return treasureId;
	}

	public void setTreasureId(int treasureId) {
		this.treasureId = treasureId;
	}

	public String getTreasureName() {
		return treasureName;
	}

	public void setTreasureName(String treasureName) {
		this.treasureName = treasureName;
	}

	public int getOpenWeek() {
		return openWeek;
	}

	public void setOpenWeek(int openWeek) {
		this.openWeek = openWeek;
	}

	public int getCost() {
		return cost;
	}

	public void setCost(int cost) {
		this.cost = cost;
	}

	public int getMaxNumber() {
		return maxNumber;
	}

	public void setMaxNumber(int maxNumber) {
		this.maxNumber = maxNumber;
	}

	public List<Integer> getReward() {
		return reward;
	}

	public void setReward(List<Integer> reward) {
		this.reward = reward;
	}

	@Override
	public String toString() {
		return "StaticTreasureShop [treasureId=" + treasureId + ", treasureName=" + treasureName + ", openWeek="
				+ openWeek + ", cost=" + cost + ", maxNumber=" + maxNumber + ", reward=" + reward + "]";
	}
}
