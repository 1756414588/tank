package com.game.domain.s;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: StaticActRedBag
 * @Description: 抢红包活动
 * @date 2018-02-01 16:15
 */
public class StaticActRedBag {
    //唯一ID
    private int id;
    //活动唯一ID
    private int activityId;
    //阶段
    private int stage;
    //需要充值金额
    private int money;
    //奖励
    private List<List<Integer>> awards;
    //返还比率
    private int ratio;
    //返还红包所需的最低充值金额
    private int mini;

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

    public int getStage() {
        return stage;
    }

    public void setStage(int stage) {
        this.stage = stage;
    }

    public int getMoney() {
        return money;
    }

    public void setMoney(int money) {
        this.money = money;
    }

    public List<List<Integer>> getAwards() {
        return awards;
    }

    public void setAwards(List<List<Integer>> awards) {
        this.awards = awards;
    }

    public int getRatio() {
        return ratio;
    }

    public void setRatio(int ratio) {
        this.ratio = ratio;
    }

    public int getMini() {
        return mini;
    }

    public void setMini(int mini) {
        this.mini = mini;
    }
}
