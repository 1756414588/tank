package com.game.domain.s;

import java.util.TreeMap;

/**
 * @author zhangdh
 * @ClassName: StaticActMedalofhonorExplore
 * @Description:荣誉勋章活动探索费用
 * @date 2017-10-30 17:41
 */
public class StaticActMedalofhonorExplore {
    private int id;
    private TreeMap<Integer, Integer> price;
    private int freeCount;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public TreeMap<Integer, Integer> getPrice() {
        return price;
    }

    public void setPrice(TreeMap<Integer, Integer> price) {
        this.price = price;
    }

    public int getFreeCount() {
        return freeCount;
    }

    public void setFreeCount(int freeCount) {
        this.freeCount = freeCount;
    }
}
