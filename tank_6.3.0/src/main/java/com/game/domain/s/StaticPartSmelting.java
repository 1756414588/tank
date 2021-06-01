package com.game.domain.s;

import java.util.List;
/**
 * 
* @ClassName: StaticPartSmelting 
* @Description: 配件淬炼
* @author
 */
public class StaticPartSmelting {
	private int kind;
	private List<Integer> cost;
	private int exp;
	private int up_weight;
	private int down_weight;
	private List<Integer> up_min;
	private List<Integer> up_max;
	private List<Integer> down_min;
	private List<Integer> down_max;
	
	public int getKind() {
		return kind;
	}
	
	public void setKind(int kind) {
		this.kind = kind;
	}
	
	public List<Integer> getCost() {
		return cost;
	}
	
	public void setCost(List<Integer> cost) {
		this.cost = cost;
	}
	
	public int getExp() {
		return exp;
	}
	
	public void setExp(int exp) {
		this.exp = exp;
	}

	public int getUp_weight() {
		return up_weight;
	}

	public void setUp_weight(int up_weight) {
		this.up_weight = up_weight;
	}

	public int getDown_weight() {
		return down_weight;
	}

	public void setDown_weight(int down_weight) {
		this.down_weight = down_weight;
	}

	public List<Integer> getUp_min() {
		return up_min;
	}

	public void setUp_min(List<Integer> up_min) {
		this.up_min = up_min;
	}

	public List<Integer> getUp_max() {
		return up_max;
	}

	public void setUp_max(List<Integer> up_max) {
		this.up_max = up_max;
	}

	public List<Integer> getDown_min() {
		return down_min;
	}

	public void setDown_min(List<Integer> down_min) {
		this.down_min = down_min;
	}

	public List<Integer> getDown_max() {
		return down_max;
	}

	public void setDown_max(List<Integer> down_max) {
		this.down_max = down_max;
	}

}
