package com.game.domain.s;

import java.util.List;

/**
 * @ClassName:StaticHeroPut
 * @author zc
 * @Description:文官进驻配置表
 * @date 2017年7月4日
 */
public class StaticHeroPut {
    private int id;
    private int partId;
    private List<Integer> heroId;
    private int boxNamber;
    private int fullSkill;
    private int fullSkillValue;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getPartId() {
        return partId;
    }

    public void setPartId(int partId) {
        this.partId = partId;
    }

    public List<Integer> getHeroId() {
        return heroId;
    }

    public void setHeroId(List<Integer> heroId) {
        this.heroId = heroId;
    }

    public int getBoxNamber() {
        return boxNamber;
    }

    public void setBoxNamber(int boxNamber) {
        this.boxNamber = boxNamber;
    }

    public int getFullSkill() {
        return fullSkill;
    }

    public void setFullSkill(int fullSkill) {
        this.fullSkill = fullSkill;
    }

    public int getFullSkillValue() {
        return fullSkillValue;
    }

    public void setFullSkillValue(int fullSkillValue) {
        this.fullSkillValue = fullSkillValue;
    }

}
