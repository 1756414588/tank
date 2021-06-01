package com.game.domain.s;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: StaticActMonopolyEvtDlg
 * @Description: 大富翁(圣诞宝藏)对话事件详细信息
 * @date 2017-11-30 14:08
 */
public class StaticActMonopolyEvtDlg {
    //唯一ID
    private int id;
    //事件ID
    private int eid;
    //消耗精力
    private int costEnergy;
    //固定奖励
    private List<List<Integer>> fixAward;
    //随机奖励
    private List<List<Integer>> rdAward;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getEid() {
        return eid;
    }

    public void setEid(int eid) {
        this.eid = eid;
    }

    public int getCostEnergy() {
        return costEnergy;
    }

    public void setCostEnergy(int costEnergy) {
        this.costEnergy = costEnergy;
    }

    public List<List<Integer>> getFixAward() {
        return fixAward;
    }

    public void setFixAward(List<List<Integer>> fixAward) {
        this.fixAward = fixAward;
    }

    public List<List<Integer>> getRdAward() {
        return rdAward;
    }

    public void setRdAward(List<List<Integer>> rdAward) {
        this.rdAward = rdAward;
    }
}
