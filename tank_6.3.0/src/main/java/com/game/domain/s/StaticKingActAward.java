package com.game.domain.s;

import java.util.List;


public class StaticKingActAward {

    private int id;
    private int awardId;
    private int type;
    private int cond;
    private List<List<Integer>> awardList;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getAwardId() {
        return awardId;
    }

    public void setAwardId(int awardId) {
        this.awardId = awardId;
    }

    public int getCond() {
        return cond;
    }

    public void setCond(int cond) {
        this.cond = cond;
    }

    public List<List<Integer>> getAwardList() {
        return awardList;
    }

    public void setAwardList(List<List<Integer>> awardList) {
        this.awardList = awardList;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }
}
