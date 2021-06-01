package com.game.cross.domain;

/**
 * @author TanDonghai @ClassName CrossShopBuy.java @Description 玩家在跨服商店的购买信息
 * @date 创建时间：2016年10月12日 上午11:32:06
 */
public class CrossShopBuy {
  /** 商品id */
  private int shopId;
  /** 玩家已购买次数 */
  private int buyNum;
  /** 全服限购商品的剩余数量 */
  private int restNum;

  public CrossShopBuy() {}

  public CrossShopBuy(com.game.pb.CommonPb.CrossShopBuy buy) {
    this.shopId = buy.getShopId();
    this.buyNum = buy.getBuyNum();
    this.restNum = buy.getRestNum();
  }

  public CrossShopBuy(int shopId, int buyNum, int restNum) {
    super();
    this.shopId = shopId;
    this.buyNum = buyNum;
    this.restNum = restNum;
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
    return "CrossShopBuy [shopId=" + shopId + ", buyNum=" + buyNum + ", restNum=" + restNum + "]";
  }
}
