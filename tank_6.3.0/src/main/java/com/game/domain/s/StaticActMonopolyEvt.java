package com.game.domain.s;

import com.game.domain.sort.IProb;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: StaticActMonopolyEvt
 * @Description: 大富翁(圣诞宝藏)事件定义
 * @date 2017-11-30 14:03
 */
public class StaticActMonopolyEvt implements IProb{
    //事件唯一ID
    private int id;
    //事件所属活动ID
    private int activityId;
    //事件出现权重
    private int prob;
    //事件类型
    private int type;
    //事件小类型
    private int sty;
    //事件随机奖励
    private List<List<Integer>> rdAward;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getActivityId() {
        return activityId;
    }

    public void setActivityId(int activityId) {
        this.activityId = activityId;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    @Override
    public int getProb() {
        return prob;
    }

    public void setProb(int prob) {
        this.prob = prob;
    }

    public List<List<Integer>> getRdAward() {
        return rdAward;
    }

    public void setRdAward(List<List<Integer>> rdAward) {
        this.rdAward = rdAward;
    }

    public int getSty() {
        return sty;
    }

    public void setSty(int sty) {
        this.sty = sty;
    }
}
