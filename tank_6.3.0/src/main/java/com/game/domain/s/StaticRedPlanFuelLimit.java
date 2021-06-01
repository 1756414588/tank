package com.game.domain.s;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/03/26 16:34
 */
public class StaticRedPlanFuelLimit {

    private int id;
    private int recoverLimit;
    private int buyLimit;
    private int recoverSpan;
    private int buyPoint;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getRecoverLimit() {
        return recoverLimit;
    }

    public void setRecoverLimit(int recoverLimit) {
        this.recoverLimit = recoverLimit;
    }

    public int getBuyLimit() {
        return buyLimit;
    }

    public void setBuyLimit(int buyLimit) {
        this.buyLimit = buyLimit;
    }

    public int getRecoverSpan() {
        return recoverSpan;
    }

    public void setRecoverSpan(int recoverSpan) {
        this.recoverSpan = recoverSpan;
    }

    public int getBuyPoint() {
        return buyPoint;
    }

    public void setBuyPoint(int buyPoint) {
        this.buyPoint = buyPoint;
    }
}
