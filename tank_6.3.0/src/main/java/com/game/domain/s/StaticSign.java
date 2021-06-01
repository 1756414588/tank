package com.game.domain.s;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-21 上午10:45:38
 * @declare 签到（前30天）
 */
public class StaticSign {
	private int signId;
	private int signDay;
	private List<List<Integer>> awardList;
	private int vip;

	public int getSignId() {
		return signId;
	}

	public void setSignId(int signId) {
		this.signId = signId;
	}

	public int getSignDay() {
		return signDay;
	}

	public void setSignDay(int signDay) {
		this.signDay = signDay;
	}

	public List<List<Integer>> getAwardList() {
		return awardList;
	}

	public void setAwardList(List<List<Integer>> awardList) {
		this.awardList = awardList;
	}

	public int getVip() {
		return vip;
	}

	public void setVip(int vip) {
		this.vip = vip;
	}

}
