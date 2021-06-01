package com.game.domain.s;

import java.util.List;
/**
* @ClassName: StaticActWorshipGodData 
* @Description: 拜神活动数据
* @author
 */
public class StaticActWorshipGodData {
	
	private int count;
	private int price;
	private List<List<Integer>> rebate;
	
	public int getCount() {
		return count;
	}
	public void setCount(int count) {
		this.count = count;
	}
	public int getPrice() {
		return price;
	}
	public void setPrice(int price) {
		this.price = price;
	}
	public List<List<Integer>> getRebate() {
		return rebate;
	}
	public void setRebate(List<List<Integer>> rebate) {
		this.rebate = rebate;
	}
	

}
