package com.game.drill.domain;

/**
 * @ClassName DrillShopBuy.java
 * @Description 红蓝大战商品状态
 * @author TanDonghai
 * @date 创建时间：2016年8月11日 下午6:30:44
 *
 */
public class DrillShopBuy {
	private int shopId = 1; // 商品id
	private int buyNum = 2; // 玩家已购买次数
	private int restNum = 3; // 全服限购商品的剩余数量

	public DrillShopBuy() {
	}

	public DrillShopBuy(com.game.pb.CommonPb.DrillShopBuy buy) {
		this.shopId = buy.getShopId();
		this.buyNum = buy.getBuyNum();
		this.restNum = buy.getRestNum();
	}

	public int getShopId() {
		return shopId;
	}

	public void setShopId(int shopId) {
		this.shopId = shopId;
	}

	public int getBuyNum() {
		return buyNum;
	}

	public void setBuyNum(int buyNum) {
		this.buyNum = buyNum;
	}

	public int getRestNum() {
		return restNum;
	}

	public void setRestNum(int restNum) {
		this.restNum = restNum;
	}

	@Override
	public String toString() {
		return "DrillShopBuy [shopId=" + shopId + ", buyNum=" + buyNum + ", restNum=" + restNum + "]";
	}

}
