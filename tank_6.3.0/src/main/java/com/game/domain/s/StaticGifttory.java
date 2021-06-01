package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 点击宝箱获得奖励, 包括叛军礼盒，大富翁礼盒
 * @created 2017/1/30 10:03
 */
public class StaticGifttory {


    private int kid;
    private List<List<Integer>> reward;
    private int maxCount;

    public int getKid() {
        return kid;
    }

    public void setKid(int id) {
        this.kid = id;
    }

    public List<List<Integer>> getReward() {
        return reward;
    }

    public void setReward(List<List<Integer>> reward) {
        this.reward = reward;
    }

    public int getMaxCount() {
        return maxCount;
    }

    public void setMaxCount(int maxCount) {
        this.maxCount = maxCount;
    }
}
