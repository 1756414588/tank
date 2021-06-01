package com.game.domain.p;

/**
 * @author GuiJie
 * @description 间谍信息
 * @created 2018/02/28 11:39
 */
public class SpyInfoData {

    private int areaId;//区域id
    private int state;//是否解锁 0未解锁 1可以解锁 2待接任务 3任务进行中 4完成
    private int taskId;//任务id
    private int time;//任务剩余时间
    private int spyId;//间谍id

    public int getAreaId() {
        return areaId;
    }

    public void setAreaId(int areaId) {
        this.areaId = areaId;
    }

    public int getState() {
        return state;
    }

    public void setState(int state) {
        this.state = state;
    }

    public int getTaskId() {
        return taskId;
    }

    public void setTaskId(int taskId) {
        this.taskId = taskId;
    }

    public int getTime() {
        return time;
    }

    public void setTime(int time) {
        this.time = time;
    }

    public int getSpyId() {
        return spyId;
    }

    public void setSpyId(int spyId) {
        this.spyId = spyId;
    }
}
