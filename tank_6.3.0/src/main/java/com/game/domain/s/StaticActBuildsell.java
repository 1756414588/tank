package com.game.domain.s;

import java.util.List;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class StaticActBuildsell {

	private int awardId;
	private List<Integer> buildingId;
	private int resource;
	private int lv;

	public int getAwardId() {
		return awardId;
	}

	public void setAwardId(int awardId) {
		this.awardId = awardId;
	}

	public List<Integer> getBuildingId() {
		return buildingId;
	}

	public void setBuildingId(List<Integer> buildingId) {
		this.buildingId = buildingId;
	}

	public int getResource() {
		return resource;
	}

	public void setResource(int resource) {
		this.resource = resource;
	}

	public int getLv() {
		return lv;
	}

	public void setLv(int lv) {
		this.lv = lv;
	}

}
