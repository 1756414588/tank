package com.game.domain.s;

import java.util.List;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class StaticBountyWanted {

	private int id;
	private long cond;
	private int type;
	private List<Integer> param;
	private int awardList;
	private String  openTime;
	private List<Integer>   openDay;
	private int   target;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public long getCond() {
		return cond;
	}

	public void setCond(long cond) {
		this.cond = cond;
	}

	public List<Integer> getParam() {
		return param;
	}

	public void setParam(List<Integer> param) {
		this.param = param;
	}

	public int getAwardList() {
		return awardList;
	}

	public void setAwardList(int awardList) {
		this.awardList = awardList;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public String getOpenTime() {
		return openTime;
	}

	public void setOpenTime(String openTime) {
		this.openTime = openTime;
	}

	public List<Integer> getOpenDay() {
		return openDay;
	}

	public void setOpenDay(List<Integer> openDay) {
		this.openDay = openDay;
	}


	public int getTarget() {
		return target;
	}

	public void setTarget(int target) {
		this.target = target;
	}
}
