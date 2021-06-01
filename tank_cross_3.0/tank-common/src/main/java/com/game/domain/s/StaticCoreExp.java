package com.game.domain.s;

/**
 * @author yeding
 * @create 2019/3/26 17:38
 */
public class StaticCoreExp {

    private int id;

    /**
     * 等级
     */
    private int level;

    /**
     * 阶段
     */
    private int section;

    /**
     * 所需经验
     */
    private int exp;

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

    public int getSection() {
        return section;
    }

    public void setSection(int section) {
        this.section = section;
    }

    public int getExp() {
        return exp;
    }

    public void setExp(int exp) {
        this.exp = exp;
    }

    @Override
    public String toString() {
        return "StaticCoreExp{" +
                "id=" + id +
                ", level=" + level +
                ", section=" + section +
                ", exp=" + exp +
                '}';
    }
}
