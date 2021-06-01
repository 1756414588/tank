package com.game.domain.s;

import java.util.List;
/**
 * 
* @ClassName: StaticCharacterChange 
* @Description: 对应s_anniversary_rule 集字对换活动
* @author
 */
public class StaticCharacterChange {
	private int id;
	private List<List<Integer>> awardId;
	private List<List<Integer>> more;
	private int itemNum;
	private int resetEveryday;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public List<List<Integer>> getAwardId() {
		return awardId;
	}

	public void setAwardId(List<List<Integer>> awardId) {
		this.awardId = awardId;
	}

	public List<List<Integer>> getMore() {
		return more;
	}

	public void setMore(List<List<Integer>> more) {
		this.more = more;
	}

	public int getItemNum() {
		return itemNum;
	}

	public void setItemNum(int itemNum) {
		this.itemNum = itemNum;
	}

	public int getResetEveryday() {
		return resetEveryday;
	}

	public void setResetEveryday(int resetEveryday) {
		this.resetEveryday = resetEveryday;
	}
	

}
