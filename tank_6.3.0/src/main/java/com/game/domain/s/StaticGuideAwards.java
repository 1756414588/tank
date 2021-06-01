package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 新手引导奖励
 * @created 2017/1/30 10:03
 */
public class StaticGuideAwards {


    private int id;
    private List<List<Integer>> awards;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public List<List<Integer>> getAwards() {
        return awards;
    }

    public void setAwards(List<List<Integer>> awards) {
        this.awards = awards;
    }
}
