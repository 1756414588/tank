package com.game.domain.s;

import java.util.List;

/**
 * @author yeding
 * @create 2019/3/26 17:40
 */
public class StaticCoreAward {

    private int id;

    /**
     * 等级
     */
    private int level;

    /**
     * 该等级熔炼解锁类型
     */
    private int type;

    /**
     * 解锁条件
     */
    private int cond;

    /**
     * 点亮奖励
     */
    private List<List<Integer>> lightAward;

    /**
     * 完成奖励
     */
    private List<List<Integer>> finishAward;

    /**
     * 描述
     */
    private String desc;

    /**
     * 位置(对应点亮加成属性)
     */
    private int index;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public int getCond() {
        return cond;
    }

    public void setCond(int cond) {
        this.cond = cond;
    }

    public List<List<Integer>> getLightAward() {
        return lightAward;
    }

    public void setLightAward(List<List<Integer>> lightAward) {
        this.lightAward = lightAward;
    }

    public List<List<Integer>> getFinishAward() {
        return finishAward;
    }

    public void setFinishAward(List<List<Integer>> finishAward) {
        this.finishAward = finishAward;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public int getIndex() {
        return index;
    }

    public void setIndex(int index) {
        this.index = index;
    }

    @Override
    public String toString() {
        return "StaticCoreAward{" +
                "id=" + id +
                ", level=" + level +
                ", type=" + type +
                ", cond=" + cond +
                ", lightAward=" + lightAward +
                ", finishAward=" + finishAward +
                ", desc='" + desc + '\'' +
                '}';
    }
}
