package com.game.domain.s;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: StaticMonthSign
 * @Description: : 月签到配置
 * @date 2017/4/17 12:05
 */
public class StaticMonthSign {
    //唯一ID
    private int id;
    //月份
    private int month;
    //累计签到天数
    private int day;
    //奖励翻倍所需的VIP等级0-不翻倍
    private int vip;
    //奖励翻倍的倍率
    private int multiple;
    //累计签到奖励
    private List<Integer> reward;
    //额外的累计签到奖励
    private List<List<Integer>> extreward;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getMonth() {
        return month;
    }

    public void setMonth(int month) {
        this.month = month;
    }

    public int getDay() {
        return day;
    }

    public void setDay(int day) {
        this.day = day;
    }

    public List<Integer> getReward() {
        return reward;
    }

    public void setReward(List<Integer> reward) {
        this.reward = reward;
    }

    public int getMultiple() {
        return multiple;
    }

    public void setMultiple(int multiple) {
        this.multiple = multiple;
    }

    public int getVip() {

        return vip;
    }

    public void setVip(int vip) {
        this.vip = vip;
    }

    public List<List<Integer>> getExtReward() {
        return extreward;
    }

    public void setExtReward(List<List<Integer>> extreward) {
        this.extreward = extreward;
    }
}
