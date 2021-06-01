package com.account.domain;

import java.util.Date;

public class Pay {
    private int keyId;
    private int platNo;
    private int childNo;
    private String platId;
    private String orderId;
    private String serialId;
    private int serverId;
    private long roleId;
    private int state;
    private int amount;
    private double realAmount;// 实际支付金额，或对账金额
    private int addGold;
    private int packId;
    private Date payTime;

    public int getKeyId() {
        return keyId;
    }

    public void setKeyId(int keyId) {
        this.keyId = keyId;
    }

    public int getPlatNo() {
        return platNo;
    }

    public void setPlatNo(int platNo) {
        this.platNo = platNo;
    }

    public int getChildNo() {
        return childNo;
    }

    public void setChildNo(int childNo) {
        this.childNo = childNo;
    }

    public String getPlatId() {
        return platId;
    }

    public void setPlatId(String platId) {
        this.platId = platId;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public String getSerialId() {
        return serialId;
    }

    public void setSerialId(String serialId) {
        this.serialId = serialId;
    }

    public int getServerId() {
        return serverId;
    }

    public void setServerId(int serverId) {
        this.serverId = serverId;
    }

    public long getRoleId() {
        return roleId;
    }

    public void setRoleId(long roleId) {
        this.roleId = roleId;
    }

    public int getState() {
        return state;
    }

    public void setState(int state) {
        this.state = state;
    }

    public int getAmount() {
        return amount;
    }

    public void setAmount(int amount) {
        this.amount = amount;
    }

    public double getRealAmount() {
        return realAmount;
    }

    public void setRealAmount(double realAmount) {
        this.realAmount = realAmount;
    }

    public Date getPayTime() {
        return payTime;
    }

    public void setPayTime(Date payTime) {
        this.payTime = payTime;
    }

    public int getAddGold() {
        return addGold;
    }

    public void setAddGold(int addGold) {
        this.addGold = addGold;
    }

    public int getPackId() {
        return packId;
    }

    public void setPackId(int packId) {
        this.packId = packId;
    }

    @Override
    public String toString() {
        return "Pay [keyId=" + keyId + ", platNo=" + platNo + ", platId="
                + platId + ", orderId=" + orderId + ", serialId=" + serialId
                + ", serverId=" + serverId + ", roleId=" + roleId + ", state="
                + state + ", amount=" + amount + ", realAmount=" + realAmount
                + ", addGold=" + addGold + ", packId=" + packId + ", payTime="
                + payTime + "]";
    }

}
