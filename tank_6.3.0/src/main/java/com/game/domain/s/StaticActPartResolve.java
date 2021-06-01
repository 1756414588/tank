package com.game.domain.s;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2016-2-29 下午4:33:45
 * @declare 分解配件兑换活动
 */

public class StaticActPartResolve {

	private int resolveId;
	private int activityId;
	/**芯片数量*/
	private int slug;
	private List<List<Integer>> awardList;
	/**[[配件,品质,得到芯片数量]...]*/
	private List<List<Integer>> resolveList;
	
	/** 仅对勋章分解生效，不同部位的勋章，在原有积分基础上乘以一定倍率 [[部位，倍率]...]*/
	private List<List<Integer>> partNum;

	public int getResolveId() {
		return resolveId;
	}

	public void setResolveId(int resolveId) {
		this.resolveId = resolveId;
	}

	public int getActivityId() {
		return activityId;
	}

	public void setActivityId(int activityId) {
		this.activityId = activityId;
	}

	public int getSlug() {
		return slug;
	}

	public void setSlug(int slug) {
		this.slug = slug;
	}

	public List<List<Integer>> getAwardList() {
		return awardList;
	}

	public void setAwardList(List<List<Integer>> awardList) {
		this.awardList = awardList;
	}

	public List<List<Integer>> getResolveList() {
		return resolveList;
	}

	public void setResolveList(List<List<Integer>> resolveList) {
		this.resolveList = resolveList;
	}

	public List<List<Integer>> getPartNum() {
		return partNum;
	}

	public void setPartNum(List<List<Integer>> partNum) {
		this.partNum = partNum;
	}
	
	

}
