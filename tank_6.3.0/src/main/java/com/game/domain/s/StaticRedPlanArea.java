package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/03/20 11:27
 */
public class StaticRedPlanArea {

    private int awardId;

    private int areaId;
    private int cost;
    private List<List<Integer>> areaAward;

    private int raidCost;
    private List<List<Integer>> raidAward;

    private List<List<Integer>> awardWeight;

    public int getRaidCost() {
        return raidCost;
    }

    public void setRaidCost(int raidCost) {
        this.raidCost = raidCost;
    }

    public List<List<Integer>> getRaidAward() {
        return raidAward;
    }

    public void setRaidAward(List<List<Integer>> raidAward) {
        this.raidAward = raidAward;
    }

    public int getAreaId() {
        return areaId;
    }

    public void setAreaId(int areaId) {
        this.areaId = areaId;
    }

    public List<List<Integer>> getAreaAward() {
        return areaAward;
    }

    public void setAreaAward(List<List<Integer>> areaAward) {
        this.areaAward = areaAward;
    }

    public int getCost() {
        return cost;
    }

    public void setCost(int cost) {
        this.cost = cost;
    }

    public int getAwardId() {
        return awardId;
    }

    public void setAwardId(int awardId) {
        this.awardId = awardId;
    }

    public List<List<Integer>> getAwardWeight() {
        return awardWeight;
    }

    public void setAwardWeight(List<List<Integer>> awardWeight) {
        this.awardWeight = awardWeight;
    }
}
