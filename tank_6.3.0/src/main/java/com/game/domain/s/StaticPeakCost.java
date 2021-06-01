package com.game.domain.s;

import java.util.List;

/**
 * @author yeding
 * @create 2019/7/20 2:38
 * @decs
 */
public class StaticPeakCost {

    private int id;

    private int skillId;

    private int loc;

    private List<List<Integer>> costSelect;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getSkillId() {
        return skillId;
    }

    public void setSkillId(int skillId) {
        this.skillId = skillId;
    }

    public int getLoc() {
        return loc;
    }

    public void setLoc(int loc) {
        this.loc = loc;
    }

    public List<List<Integer>> getCostSelect() {
        return costSelect;
    }

    public void setCostSelect(List<List<Integer>> costSelect) {
        this.costSelect = costSelect;
    }

    @Override
    public String toString() {
        return "StaticPeakCost{" +
                "id=" + id +
                ", skillId=" + skillId +
                ", loc=" + loc +
                ", costSelect=" + costSelect +
                '}';
    }
}
