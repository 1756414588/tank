package com.game.domain.s;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: StaticActMedalofhonorRule
 * @Description:荣誉勋章活动积分兑换
 * @date 2017-10-31 16:33
 */
public class StaticActMedalofhonorRule {
    private int id;
    private List<Integer> awards;
    private int cost;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public List<Integer> getAwards() {
        return awards;
    }

    public void setAwards(List<Integer> awards) {
        this.awards = awards;
    }

    public int getCost() {
        return cost;
    }

    public void setCost(int cost) {
        this.cost = cost;
    }
}
