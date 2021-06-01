package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/03/20 11:27
 */
public class StaticRedPlanShop {
    private int awardId;
    private int goodId;
    private List<Integer> cost;
    private int personNumber;

    private List<Integer> reward;

    public int getGoodId() {
        return goodId;
    }

    public void setGoodId(int goodId) {
        this.goodId = goodId;
    }

    public int getPersonNumber() {
        return personNumber;
    }

    public void setPersonNumber(int personNumber) {
        this.personNumber = personNumber;
    }

    public int getAwardId() {
        return awardId;
    }

    public void setAwardId(int awardId) {
        this.awardId = awardId;
    }

    public List<Integer> getCost() {
        return cost;
    }

    public void setCost(List<Integer> cost) {
        this.cost = cost;
    }

    public List<Integer> getReward() {
        return reward;
    }

    public void setReward(List<Integer> reward) {
        this.reward = reward;
    }
}
