package com.game.domain.s;

import java.util.List;
/**
* @ClassName: StaticMedalUp 
* @Description: TODO
* @author
 */
public class StaticMedalUp {
	private int quality;
	private int lv;
	private int exp;
	private int bonusExp;
	private int bonusLv;
	private List<List<Integer>> cost;
	private List<List<Integer>> explode;
	private int leastExp;

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

	public int getExp() {
		return exp;
	}

	public void setExp(int exp) {
		this.exp = exp;
	}

	public int getBonusExp() {
		return bonusExp;
	}

	public void setBonusExp(int bonusExp) {
		this.bonusExp = bonusExp;
	}

	public int getBonusLv() {
		return bonusLv;
	}

	public void setBonusLv(int bonusLv) {
		this.bonusLv = bonusLv;
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

	public int getLeastExp() {
		return leastExp;
	}

	public void setLeastExp(int leastExp) {
		this.leastExp = leastExp;
	}
	
}
