package com.game.domain.s;

import java.util.List;
/**
* @ClassName: StaticMedalBouns 
* @Description: 勋章额外属性
* @author
 */
public class StaticMedalBouns {
	private int number;
	private List<List<Integer>> bonus;
	
	public int getNumber() {
		return number;
	}
	public void setNumber(int number) {
		this.number = number;
	}
	public List<List<Integer>> getBonus() {
		return bonus;
	}
	public void setBonus(List<List<Integer>> bonus) {
		this.bonus = bonus;
	}
}
