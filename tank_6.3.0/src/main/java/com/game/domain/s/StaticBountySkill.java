package com.game.domain.s;

import java.util.List;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class StaticBountySkill {
    private int id;
    private int type;
    private List<List<Integer>> param;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public List<List<Integer>> getParam() {
        return param;
    }

    public void setParam(List<List<Integer>> param) {
        this.param = param;
    }
}
