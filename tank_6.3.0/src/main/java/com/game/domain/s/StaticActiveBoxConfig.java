package com.game.domain.s;

import java.util.ArrayList;
import java.util.List;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class StaticActiveBoxConfig {
	
	private int id;
	private int prob;
	private int refreshCap;	//单日刷新上限
	private int minCap;
	private int restoreCap;	//存储上限
	private int openlevel;	//开启等级
	private List<List<Integer>> award = new ArrayList<>();



	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getProb() {
		return prob;
	}

	public void setProb(int prob) {
		this.prob = prob;
	}

	public int getRefreshCap() {
		return refreshCap;
	}

	public void setRefreshCap(int refreshCap) {
		this.refreshCap = refreshCap;
	}

	public int getMinCap() {
		return minCap;
	}

	public void setMinCap(int minCap) {
		this.minCap = minCap;
	}

	public int getRestoreCap() {
		return restoreCap;
	}

	public void setRestoreCap(int restoreCap) {
		this.restoreCap = restoreCap;
	}

	public List<List<Integer>> getAward() {
		return award;
	}

	public void setAward(List<List<Integer>> award) {
		this.award = award;
	}

	public int getOpenlevel() {
		return openlevel;
	}

	public void setOpenlevel(int openlevel) {
		this.openlevel = openlevel;
	}
}
