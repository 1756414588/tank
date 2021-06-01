package com.game.domain.s;

/**
 * @author yeding
 * @create 2019/7/20 2:14
 * @decs
 */
public class StaticPeakLv {

    private int id;

    private int lv;

    private long exp;

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

    public long getExp() {
        return exp;
    }

    public void setExp(long exp) {
        this.exp = exp;
    }

    @Override
    public String toString() {
        return "StaticPeakLv{" +
                "id=" + id +
                ", lv=" + lv +
                ", exp=" + exp +
                '}';
    }
}
