package com.game.domain.s;

import java.util.List;

/**
 * 狂欢祈福
 */
public class StaticActHilarityPray {
	
	private int id;
	private int type;
	private int value;
	private List<List<Integer>> awards;
	
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public int getType() {
		return type;
	}
	public void setType(int type) {
		this.type = type;
	}
	public int getValue() {
		return value;
	}
	public void setValue(int value) {
		this.value = value;
	}
	public List<List<Integer>> getAwards() {
		return awards;
	}
	public void setAwards(List<List<Integer>> awards) {
		this.awards = awards;
	}
	
}
