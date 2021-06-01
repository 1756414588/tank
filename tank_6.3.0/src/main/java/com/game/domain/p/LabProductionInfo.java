package com.game.domain.p;

/**
 * @author GuiJie
 * @description 作战研究院资源生产数据
 * @created 2017/12/26 15:21
 */
public class LabProductionInfo {
    /**
     * @param resourceId 资源id
     * @param state      资源生产状态
     * @param time       资源已经生产的时间
     */
    public LabProductionInfo(int resourceId, int state, int time) {
        this.resourceId = resourceId;
        this.state = state;
        this.time = time;
    }

    /**
     * 资源id
     */
    private int resourceId;
    /**
     * 资源生产状态
     */
    private int state;
    /**
     * 资源已经生产的时间
     */
    private int time;

    public int getResourceId() {
        return resourceId;
    }

    public void setResourceId(int resourceId) {
        this.resourceId = resourceId;
    }

    public int getState() {
        return state;
    }

    public void setState(int state) {
        this.state = state;
    }

    public int getTime() {
        return time;
    }

    public void setTime(int time) {
        this.time = time;
    }
}
