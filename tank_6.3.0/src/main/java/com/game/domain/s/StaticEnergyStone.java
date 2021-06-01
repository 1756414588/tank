package com.game.domain.s;

/**
 * @ClassName: StaticEnergyStone
 * @Description: 能晶信息配置信息
 * @author TanDonghai
 * @date 创建时间：2016年7月12日 下午3:23:10
 *
 */
public class StaticEnergyStone {
	private int stoneId;// 能晶id
	private String stoneName;// 能晶名称
	private int level;// 能晶等级
	private int attrId;// 属性类型
	private int attrValue;// 属性百分比，比如增加10%，就填10
	private int synthesizing;// 合成ID，必须为stondID
	private int holeType;// 可以镶嵌的孔类型，1 红色，2 蓝色，3 黄色

	public int getStoneId() {
		return stoneId;
	}

	public void setStoneId(int stoneId) {
		this.stoneId = stoneId;
	}

	public String getStoneName() {
		return stoneName;
	}

	public void setStoneName(String stoneName) {
		this.stoneName = stoneName;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public int getAttrId() {
		return attrId;
	}

	public void setAttrId(int attrId) {
		this.attrId = attrId;
	}

	public int getAttrValue() {
		return attrValue;
	}

	public void setAttrValue(int attrValue) {
		this.attrValue = attrValue;
	}

	public int getSynthesizing() {
		return synthesizing;
	}

	public void setSynthesizing(int synthesizing) {
		this.synthesizing = synthesizing;
	}

	public int getHoleType() {
		return holeType;
	}

	public void setHoleType(int holeType) {
		this.holeType = holeType;
	}

	@Override
	public String toString() {
		return "StaticEnergyStone [stoneId=" + stoneId + ", stoneName=" + stoneName + ", level=" + level + ", attrId="
				+ attrId + ", attrValue=" + attrValue + ", synthesizing=" + synthesizing + ", holeType=" + holeType
				+ "]";
	}
}
