package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/03/20 11:27
 */
public class StaticRedPlanPoint {
    private int awardId;
    private int pid;
    private int type;
    private List<Integer> prePoint;
    private int possibility;
    private int areaInclude;
    private List<List<Integer>> award;
    private List<List<Integer>> awardWeight;


    public int getPid() {
        return pid;
    }

    public void setPid(int pid) {
        this.pid = pid;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public List<Integer> getPrePoint() {
        return prePoint;
    }

    public void setPrePoint(List<Integer> prePoint) {
        this.prePoint = prePoint;
    }

    public int getPossibility() {
        return possibility;
    }

    public void setPossibility(int possibility) {
        this.possibility = possibility;
    }

    public List<List<Integer>> getAward() {
        return award;
    }

    public void setAward(List<List<Integer>> award) {
        this.award = award;
    }

    public int getAreaInclude() {
        return areaInclude;
    }

    public void setAreaInclude(int areaInclude) {
        this.areaInclude = areaInclude;
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
