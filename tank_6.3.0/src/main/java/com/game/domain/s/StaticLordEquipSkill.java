package com.game.domain.s;

import java.util.List;

/**
 * @ClassName:StaticLordEquipSkill
 * @Description:军备技能数据配置
 * @author zc
 * @date 2017年6月14日
 */
public class StaticLordEquipSkill {
	private int id;

	// 技能类型
	private int type;

	// 技能等级
	private int level;

	// 属性 [[2,100],[4,200]]
	private List<List<Integer>> attrs;

	// 带兵量
	private int tankCount;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public List<List<Integer>> getAttrs() {
		return attrs;
	}

	public void setAttrs(List<List<Integer>> attrs) {
		this.attrs = attrs;
	}

	public int getTankCount() {
		return tankCount;
	}

	public void setTankCount(int tankCount) {
		this.tankCount = tankCount;
	}

}
