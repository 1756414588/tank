package com.game.domain.s;

import java.util.List;
/**
* @ClassName: StaticActWorshipTask 
* @Description: 拜神活动任务
* @author
 */
public class StaticActWorshipTask {
	
	private int keyId;
	private int awardId;
	private int day;	
	private List<List<Integer>> task;
	private List<List<Integer>> awards;
	
	public int getKeyId() {
		return keyId;
	}
	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}
	public int getAwardId() {
		return awardId;
	}
	public void setAwardId(int awardId) {
		this.awardId = awardId;
	}
	public int getDay() {
		return day;
	}
	public void setDay(int day) {
		this.day = day;
	}
	public List<List<Integer>> getTask() {
		return task;
	}
	public void setTank(List<List<Integer>> task) {
		this.task = task;
	}
	public List<List<Integer>> getAwards() {
		return awards;
	}
	public void setAwards(List<List<Integer>> awards) {
		this.awards = awards;
	}
	

}
