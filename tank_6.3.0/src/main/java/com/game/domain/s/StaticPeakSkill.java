package com.game.domain.s;

import java.util.List;

/**
 * @author yeding
 * @create 2019/7/20 2:40
 * @decs
 */
public class StaticPeakSkill {

    private int id;

    private int lv;

    private int type;

    private List<Integer> before;

    private List<Integer> after;

    private List<List<Integer>> cost;

    private int costSkill;

    private List<List<Integer>> attr;

    private List<List<Integer>> itemGet;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getLv() {
        return lv;
    }

    public void setLv(int lv) {
        this.lv = lv;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public List<Integer> getBefore() {
        return before;
    }

    public void setBefore(List<Integer> before) {
        this.before = before;
    }

    public List<Integer> getAfter() {
        return after;
    }

    public void setAfter(List<Integer> after) {
        this.after = after;
    }

    public List<List<Integer>> getCost() {
        return cost;
    }

    public void setCost(List<List<Integer>> cost) {
        this.cost = cost;
    }

    public int getCostSkill() {
        return costSkill;
    }

    public void setCostSkill(int costSkill) {
        this.costSkill = costSkill;
    }

    public List<List<Integer>> getAttr() {
        return attr;
    }

    public void setAttr(List<List<Integer>> attr) {
        this.attr = attr;
    }

    public List<List<Integer>> getItemGet() {
        return itemGet;
    }

    public void setItemGet(List<List<Integer>> itemGet) {
        this.itemGet = itemGet;
    }

    @Override
    public String toString() {
        return "StaticPeakSkill{" +
                "id=" + id +
                ", lv=" + lv +
                ", type=" + type +
                ", before=" + before +
                ", after=" + after +
                ", cost=" + cost +
                ", costSkill=" + costSkill +
                ", attr=" + attr +
                ", itemGet=" + itemGet +
                '}';
    }
}
