package com.game.domain.s;

import java.util.List;
/**
* @ClassName: StaticActivityM1a2 
* @Description: m1a2活动
* @author
 */
public class StaticActivityM1a2 {
	private int id;
//	private int activityId;
//	private String name;
	private int tankId;
	private List<List<Integer>> awards;
	private int priceOne;
	private int priceTen;
	
	public int getId() {
		return id;
	}
	
	public void setId(int id) {
		this.id = id;
	}
	
	public int getTankId() {
		return tankId;
	}

	public void setTankId(int tankId) {
		this.tankId = tankId;
	}

	public List<List<Integer>> getAwards() {
		return awards;
	}
	
	public void setAwards(List<List<Integer>> awards) {
		this.awards = awards;
	}

	public int getPriceOne() {
		return priceOne;
	}

	public void setPriceOne(int priceOne) {
		this.priceOne = priceOne;
	}

	public int getPriceTen() {
		return priceTen;
	}

	public void setPriceTen(int priceTen) {
		this.priceTen = priceTen;
	}
}
