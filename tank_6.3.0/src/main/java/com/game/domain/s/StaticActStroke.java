package com.game.domain.s;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: StaticActStroke
 * @Description: 闪击行动
 * @date 2018-01-17 18:47
 */
public class StaticActStroke {
    //唯一ID
    private int id;
    //活动KeyId
    private int activityId;
    //领取周期,单位:秒
    private int period;
    //奖励
    private List<List<Integer>> award;

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

    public int getPeriod() {
        return period;
    }

    public void setPeriod(int period) {
        this.period = period;
    }

    public List<List<Integer>> getAward() {
        return award;
    }

    public void setAward(List<List<Integer>> award) {
        this.award = award;
    }
}
