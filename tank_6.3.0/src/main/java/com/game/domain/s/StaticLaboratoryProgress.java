package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 描述
 * @created 2017/12/20 10:03
 */
public class StaticLaboratoryProgress {


    private int id;
    private List<Integer> progress;
    private List<List<Integer>> award;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public List<Integer> getProgress() {
        return progress;
    }

    public void setProgress(List<Integer> progress) {
        this.progress = progress;
    }

    public List<List<Integer>> getAward() {
        return award;
    }

    public void setAward(List<List<Integer>> award) {
        this.award = award;
    }
}
