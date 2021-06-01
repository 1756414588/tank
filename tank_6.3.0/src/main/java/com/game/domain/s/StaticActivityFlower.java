package com.game.domain.s;

import java.util.List;
/**
* @ClassName: StaticActivityFlower 
* @Description: 鲜花祝福活动
* @author
 */
public class StaticActivityFlower {
	
	private int id;
	private int itemNum;
	private List<List<Integer>> more;
	private List<List<Integer>> awards;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getItemNum() {
		return itemNum;
	}

	public void setItemNum(int itemNum) {
		this.itemNum = itemNum;
	}

	public List<List<Integer>> getMore() {
		return more;
	}

	public void setMore(List<List<Integer>> more) {
		this.more = more;
	}

	public List<List<Integer>> getAwards() {
		return awards;
	}

	public void setAwards(List<List<Integer>> awards) {
		this.awards = awards;
	}
	

}
