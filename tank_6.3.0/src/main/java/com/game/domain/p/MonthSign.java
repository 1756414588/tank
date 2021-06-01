package com.game.domain.p;

import java.util.HashSet;
import java.util.Set;

/**
 * @author zhangdh
 * @ClassName: MonthSign
 * @Description: 每月签到(新版)
 * @date 2017/4/17 09:59
 */
public class MonthSign {
    private int todaySign;//0-今日未签到,1-今日已签到,2-今日已签到并且有VIP加成
    private int signMonth;
    private int signDay;
    private int days;//本月累计签到天数
    private Set<Integer> ext = new HashSet<>();//已领取的累计签到的额外奖励

    public void resetDay() {
        todaySign = 0;
    }

    public void resetMonth(int month) {
        resetDay();
        signDay = 0;
        signMonth = month;
        days = 0;
        ext.clear();
    }

    public int getDays() {
        return days;
    }

    public void setDays(int days) {
        this.days = days;
    }

    public int getTodaySign() {
        return todaySign;
    }

    public void setTodaySign(int todaySign) {
        this.todaySign = todaySign;
    }

    public Set<Integer> getExt() {
        return ext;
    }

    public void setExt(Set<Integer> ext) {
        this.ext = ext;
    }

    public int getSignMonth() {
        return signMonth;
    }

    public void setSignMonth(int signMonth) {
        this.signMonth = signMonth;
    }

    public int getSignDay() {
        return signDay;
    }

    public void setSignDay(int signDay) {
        this.signDay = signDay;
    }

    @Override
    public String toString() {
        return String.format("days :%d, todaySign :%d, sign month :%d, day :%d", days, todaySign, signMonth, signDay);
    }
}
