package com.game.domain.s;

/**
 * @author zhangdh
 * @ClassName: StaticTechnical
 * @Description: 军备打造技师
 * @date 2017/4/21 09:58
 */
public class StaticTechnical {
    private int id;
    private int prosLevel;//所需繁荣度等级
    private int cost;//雇佣花费
    private int workTime;//雇佣后持续时间
    private int timeDown;//减少装备打造时间

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getProsLevel() {
        return prosLevel;
    }

    public void setProsLevel(int prosLevel) {
        this.prosLevel = prosLevel;
    }

    public int getCost() {
        return cost;
    }

    public void setCost(int cost) {
        this.cost = cost;
    }

    public int getWorkTime() {
        return workTime;
    }

    public void setWorkTime(int workTime) {
        this.workTime = workTime;
    }

    public int getTimeDown() {
        return timeDown;
    }

    public void setTimeDown(int timeDown) {
        this.timeDown = timeDown;
    }
}
