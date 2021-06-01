package com.game.domain.s;

import java.util.List;

/**
* @ClassName: StaticMedalRefit 
* @Description: 勋章打磨系数配置
* @author
 */
public class StaticMedalRefit {
	private int quality;
	private int lv;
	private List<List<Integer>> cost;
	private List<List<Integer>> explode;
	
	public int getQuality() {
		return quality;
	}
	
	public void setQuality(int quality) {
		this.quality = quality;
	}
	
	public int getLv() {
		return lv;
	}
	
	public void setLv(int lv) {
		this.lv = lv;
	}

	public List<List<Integer>> getCost() {
		return cost;
	}

	public void setCost(List<List<Integer>> cost) {
		this.cost = cost;
	}

	public List<List<Integer>> getExplode() {
		return explode;
	}

	public void setExplode(List<List<Integer>> explode) {
		this.explode = explode;
	}

}
