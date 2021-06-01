package com.game.domain.p;

import java.util.HashMap;
import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: Shop
 * @Description: 商店信息
 * @date 2017/4/6 17:38
 */
public class Shop {
    private int sty;//商店类型
    private int refreashTime;//商店刷新时间
    private Map<Integer, ShopBuy> buyMap = new HashMap<>();

    public Shop() {
    }

    public Shop(int sty, int refreashTime) {
        this.sty = sty;
        this.refreashTime = refreashTime;
    }

    public int getSty() {
        return sty;
    }

    public void setSty(int sty) {
        this.sty = sty;
    }

    public int getRefreashTime() {
        return refreashTime;
    }

    public void setRefreashTime(int refreashTime) {
        this.refreashTime = refreashTime;
    }

    public Map<Integer, ShopBuy> getBuyMap() {
        return buyMap;
    }
}
