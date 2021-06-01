package com.game.domain.s;

import java.util.List;

/**
 * @ClassName:StaticLordEquipChange
 * @Description:军备技能洗炼数据
 * @author zc
 * @date 2017年6月14日
 */
public class StaticLordEquipChange {
	private int id;

	private String name;

	// 技能等级上升概率。万分数
	private int upProp;

	// 技能类型变动权重 [[1,100],[2,100],[3,100]]。第一个整数表示洗练的type，第二个整数表示该type对应的权重。
	private List<List<Integer>> typeProp;

	// 花费
	private int cost;

	// 多长时间恢复一次洗练次数 单位：s （负数表示不随时间恢复）
	private int cd;

	// 洗练次数最大储存量，超过的次数将不在加入。
	private int keepNumber;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getUpProp() {
		return upProp;
	}

	public void setUpPropint(int upProp) {
		this.upProp = upProp;
	}

	public List<List<Integer>> getTypeProp() {
		return typeProp;
	}

	public void setTypeProp(List<List<Integer>> typeProp) {
		this.typeProp = typeProp;
	}

	public int getCost() {
		return cost;
	}

	public void setCost(int cost) {
		this.cost = cost;
	}

	public int getCd() {
		return cd;
	}

	public void setCd(int cd) {
		this.cd = cd;
	}

	public int getKeepNumber() {
		return keepNumber;
	}

	public void setKeepNumber(int keepNumber) {
		this.keepNumber = keepNumber;
	}

}
