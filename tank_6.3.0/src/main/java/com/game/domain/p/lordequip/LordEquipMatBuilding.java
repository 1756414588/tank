package com.game.domain.p.lordequip;

import com.game.domain.p.AbsBuilding;

/**
 * @author zhangdh
 * @ClassName: LordEquipMatBuilding
 * @Description: 军备材料生产
 * @date 2017/4/26 13:44
 */
public class LordEquipMatBuilding extends AbsBuilding implements Comparable<LordEquipMatBuilding> {

    //已经完成的生产量
    private long complete;

    //生产速度
    private long speed;

    //最后更新时间
    private int lastTime;

    /**
     * 初始化一个军备材料的生产对象
     *
     * @param pid    材料ID
     * @param count  生产数量
     * @param speed  生产速度
     * @param period 总生产量
     */
    public LordEquipMatBuilding(int pid, int count, long period) {
        this.staticId = pid;
        this.count = count;
        this.period = period;
    }

    public LordEquipMatBuilding(int pid, int count) {
        this.staticId = pid;
        this.count = count;
    }

    @Override
    public int compareTo(LordEquipMatBuilding o) {
        double f0 = complete * 1.0 / period;
        double f1 = o.complete * 1.0 / o.period;
        if (f0 < f1) {
            return 1;
        } else if (f0 > f1) {
            return -1;
        } else {
            return this.staticId >= o.staticId ? -1 : 1;
        }
    }

    public long getComplete() {
        return complete;
    }

    public void setComplete(long complete) {
        this.complete = complete;
    }

    public long getSpeed() {
        return speed;
    }

    public void setSpeed(long speed) {
        this.speed = speed;
    }

    public int getLastTime() {
        return lastTime;
    }

    public void setLastTime(int lastTime) {
        this.lastTime = lastTime;
    }
}
