package com.game.service.cross.fight;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/13 11:34
 * @description：
 */
public class PushStateInfo {
    private int day;
    private String beginTime;
    private String endTime;
    private int id;

    public PushStateInfo(int day, String beginTime, String endTime, int id) {
        super();
        this.day = day;
        this.beginTime = beginTime;
        this.endTime = endTime;
        this.id = id;
    }

    public int getDay() {
        return day;
    }

    public void setDay(int day) {
        this.day = day;
    }

    public String getBeginTime() {
        return beginTime;
    }

    public void setBeginTime(String beginTime) {
        this.beginTime = beginTime;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }
}
