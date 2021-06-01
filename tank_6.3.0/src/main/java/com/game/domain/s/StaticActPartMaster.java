package com.game.domain.s;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: StaticActPartMaster
 * @Description: 淬炼大师获得氪金表
 * @date 2017-05-31 14:49
 */
public class StaticActPartMaster {
    //唯一ID
    private int id;
    //淬炼方式： 1为普通，2为专家，3为大师
    private int mode;
    //获得氪金概率与数量[[数量,概率],[数量,概率],[数量,概率]...]
    private List<List<Integer>> prob;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getMode() {
        return mode;
    }

    public void setMode(int mode) {
        this.mode = mode;
    }

    public List<List<Integer>> getProb() {
        return prob;
    }

    public void setProb(List<List<Integer>> prob) {
        this.prob = prob;
    }
}
