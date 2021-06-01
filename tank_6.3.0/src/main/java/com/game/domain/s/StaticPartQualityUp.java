package com.game.domain.s;

import java.util.List;

/**
 * 配件进阶
 * @author I
 *
 */
public class StaticPartQualityUp {
	
	private int partId;
	private int transformPart;  // 进阶后的id
	private int type;
	private int discont;  // 返还率
	private List<List<Integer>> costList; // 消耗物品

	public int getPartId() {
		return partId;
	}

	public void setPartId(int partId) {
		this.partId = partId;
	}

	public int getTransformPart() {
		return transformPart;
	}

	public void setTransformPart(int transformPart) {
		this.transformPart = transformPart;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getDiscont() {
		return discont;
	}

	public void setDiscont(int discont) {
		this.discont = discont;
	}

	public List<List<Integer>> getCostList() {
		return costList;
	}

	public void setCostList(List<List<Integer>> costList) {
		this.costList = costList;
	}

}
