package com.game.domain.s;

import java.util.List;

/**
 * @ClassName StaticDrillBuff.java
 * @Description 红蓝大战buff配置
 * @author TanDonghai
 * @date 创建时间：2016年8月11日 下午7:18:59
 *
 */
public class StaticDrillBuff {
	private int buffId;// buffID

	private int object;// buff作用对象。1，己方阵营；2，敌方阵营。

	private int lv;// buff当前等级

	private int exp;// buff升级到下一级所需要的经验

	private int attrId;// buff作用的类型

	private int attrValue;// buff强度

	private List<Integer> costList;// 升级消耗

	public int getBuffId() {
		return buffId;
	}

	public void setBuffId(int buffId) {
		this.buffId = buffId;
	}

	public int getObject() {
		return object;
	}

	public void setObject(int object) {
		this.object = object;
	}

	public int getLv() {
		return lv;
	}

	public void setLv(int lv) {
		this.lv = lv;
	}

	public int getExp() {
		return exp;
	}

	public void setExp(int exp) {
		this.exp = exp;
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

	public List<Integer> getCostList() {
		return costList;
	}

	public void setCostList(List<Integer> costList) {
		this.costList = costList;
	}

	@Override
	public String toString() {
		return "StaticDrillBuff [buffId=" + buffId + ", object=" + object + ", lv=" + lv + ", exp=" + exp + ", attrId="
				+ attrId + ", attrValue=" + attrValue + ", costList=" + costList + "]";
	}

}
