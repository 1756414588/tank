package com.game.domain.p;

/**
 * @ClassName TreasureShopBuy.java
 * @Description 记录玩家购买荒宝碎片兑换商店（宝物商店）的购买信息
 * @author TanDonghai
 * @date 创建时间：2016年8月3日 下午4:24:21
 *
 */
public class TreasureShopBuy {

	private int treasureId; // 购买的宝物id

	private int buyNum;// 已购买次数

	private int buyWeek;// 最后一次购买该物品的是开服第几周

	public TreasureShopBuy() {
	}

	public TreasureShopBuy(int treasureId, int buyNum, int buyWeek) {
		this.treasureId = treasureId;
		this.buyNum = buyNum;
		this.buyWeek = buyWeek;
	}
	
	public int getTreasureId() {
		return treasureId;
	}

	public void setTreasureId(int treasureId) {
		this.treasureId = treasureId;
	}

	public int getBuyNum() {
		return buyNum;
	}

	public void setBuyNum(int buyNum) {
		this.buyNum = buyNum;
	}

	public int getBuyWeek() {
		return buyWeek;
	}

	public void setBuyWeek(int buyWeek) {
		this.buyWeek = buyWeek;
	}

	@Override
	public String toString() {
		return "TreasureShopBuy [treasureId=" + treasureId + ", buyNum=" + buyNum + ", buyWeek=" + buyWeek + "]";
	}
}
