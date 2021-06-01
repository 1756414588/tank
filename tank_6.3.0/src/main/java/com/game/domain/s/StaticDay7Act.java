package com.game.domain.s;

import java.util.List;
/**
* @ClassName: StaticDay7Act 
* @Description: 7天活动配置
* @author
 */
public class StaticDay7Act {
	private int keyId;
	private int type;
	private int day;
	private int gotoUi;
	private int cond;
	private List<List<Integer>> awardList;
	private List<Integer> param;

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getDay() {
		return day;
	}

	public void setDay(int day) {
		this.day = day;
	}

	public int getGotoUi() {
		return gotoUi;
	}

	public void setGotoUi(int gotoUi) {
		this.gotoUi = gotoUi;
	}

	public int getCond() {
		return cond;
	}

	public void setCond(int cond) {
		this.cond = cond;
	}

	public List<List<Integer>> getAwardList() {
		return awardList;
	}

	public void setAwardList(List<List<Integer>> awardList) {
		this.awardList = awardList;
	}

	public List<Integer> getParam() {
		return param;
	}

	public void setParam(List<Integer> param) {
		this.param = param;
	}

}
