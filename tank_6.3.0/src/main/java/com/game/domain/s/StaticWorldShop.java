package com.game.domain.s;

import java.util.List;
import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: StaticWorldShop
 * @Description: 世界商店
 * @date 2017/4/6 19:21
 */
public class StaticWorldShop {
    private int gid;
    private List<Integer> reward;
    private int price;
    private int levelLimit;
    /** KEY: 世界等级,VALUE [世界等级,折扣万分比,购买次数]*/
    private Map<Integer, List<Integer>> discountAndNmuber;

    public int getGid() {
        return gid;
    }

    public void setGid(int gid) {
        this.gid = gid;
    }

    public List<Integer> getReward() {
        return reward;
    }

    public void setReward(List<Integer> reward) {
        this.reward = reward;
    }

    public int getPrice() {
        return price;
    }

    public void setPrice(int price) {
        this.price = price;
    }

    public Map<Integer, List<Integer>> getDiscountAndNmuber() {
        return discountAndNmuber;
    }

    public void setDiscountAndNmuber(Map<Integer, List<Integer>> discountAndNmuber) {
        this.discountAndNmuber = discountAndNmuber;
    }

    public int getLevelLimit() {
        return levelLimit;
    }

    public void setLevelLimit(int levelLimit) {
        this.levelLimit = levelLimit;
    }
}
