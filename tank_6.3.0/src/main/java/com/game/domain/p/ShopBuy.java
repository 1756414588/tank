package com.game.domain.p;

/**
 * @author zhangdh
 * @ClassName: ShopBuy
 * @Description: 商店单个购买信息
 * @date 2017/4/6 17:33
 */
public class ShopBuy {
    private int gid;
    private int buyCount;

    public ShopBuy(int gid, int buyCount) {
        this.gid = gid;
        this.buyCount = buyCount;
    }

    public int getGid() {
        return gid;
    }

    public void setGid(int gid) {
        this.gid = gid;
    }

    public int getBuyCount() {
        return buyCount;
    }

    public void setBuyCount(int buyCount) {
        this.buyCount = buyCount;
    }
}
