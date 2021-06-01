package com.game.domain.s;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: StaticLordEquip
 * @Description: 指挥官军备定义
 * @date 2017/4/21 14:17
 */
public class StaticLordEquip {
    private int id;
    private int pos;
    private int quality;
    private int level;
    private int formula;
    private int tankCount;
    private List<List<Integer>> atts;
    
    private int normalBox;		//普通洗练格子数量
    private int superBox;		//是否神秘洗练(0不能洗练，1可以洗练)
    private int maxSkillLevel;	//技能最大可升级等级

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getPos() {
        return pos;
    }

    public void setPos(int pos) {
        this.pos = pos;
    }

    public int getQuality() {
        return quality;
    }

    public void setQuality(int quality) {
        this.quality = quality;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public int getFormula() {
        return formula;
    }

    public void setFormula(int formula) {
        this.formula = formula;
    }

    public List<List<Integer>> getAtts() {
        return atts;
    }

    public void setAtts(List<List<Integer>> atts) {
        this.atts = atts;
    }

    public int getTankCount() {
        return tankCount;
    }

    public void setTankCount(int tankCount) {
        this.tankCount = tankCount;
    }

	public int getNormalBox() {
		return normalBox;
	}

	public void setNormalBox(int normalBox) {
		this.normalBox = normalBox;
	}

	public int getSuperBox() {
		return superBox;
	}

	public void setSuperBox(int superBox) {
		this.superBox = superBox;
	}

	public int getMaxSkillLevel() {
		return maxSkillLevel;
	}

	public void setMaxSkillLevel(int maxSkillLevel) {
		this.maxSkillLevel = maxSkillLevel;
	}

	/**
	 * @return
	 */
	public boolean canSuperChange() {
		return superBox == 1;
	}
    
}
