package com.account.plat;

public class PayInfo {
    /**
     * 游戏内部渠道号
     */
    public int platNo;
    /**
     * 游戏内部子渠道号
     */
    public int childNo;
    /**
     * 渠道用户id
     */
    public String platId;
    /**
     * 渠道订单号
     */
    public String orderId;
    /**
     * 游戏内部订单号
     */
    public String serialId;
    /**
     * 游戏区号
     */
    public int serverId;
    /**
     * 玩家角色id
     */
    public long roleId;
    /**
     * 付费金额（国内单位是元，国外暂定）
     */
    public int amount;
    /**
     * 实际支付金额，或对账金额
     */
    public double realAmount;
    /**
     * 商品礼包id
     */
    public int packId;
}
