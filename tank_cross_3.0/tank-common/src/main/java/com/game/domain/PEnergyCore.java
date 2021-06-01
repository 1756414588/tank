package com.game.domain;

/**
 * @author yeding
 * @create 2019/3/25 14:51
 */
public class PEnergyCore {

    /**
     * 当前处于等级
     */
    private int level;

    /**
     * 当前处于阶段
     */
    private int section;

    private int state;


    public PEnergyCore() {

    }

    public PEnergyCore(int level, int sec, int state) {
        this.level = level;
        this.section = sec;
        this.state = state;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public int getSection() {
        return section;
    }

    public void setSection(int section) {
        this.section = section;
    }

    public int getState() {
        return state;
    }

    public void setState(int state) {
        this.state = state;
    }
}
