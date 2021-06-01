package com.game.domain.s;

import java.util.List;
/**
* @ClassName: StaticActRebel 
* @Description: 叛军活动
* @author
 */
public class StaticActRebel {
	private int number;
	private int maxNumber;
	private List<Integer> hour;
	private List<Integer> minute;
	private int haustRatio;
	private int speedArmy;
	private int point;
	private List<List<Integer>> pointPerTime;

	public int getNumber() {
		return number;
	}

	public void setNumber(int number) {
		this.number = number;
	}

	public int getMaxNumber() {
		return maxNumber;
	}

	public void setMaxNumber(int maxNumber) {
		this.maxNumber = maxNumber;
	}

	public List<Integer> getHour() {
		return hour;
	}

	public void setHour(List<Integer> hour) {
		this.hour = hour;
	}

	public List<Integer> getMinute() {
		return minute;
	}

	public void setMinute(List<Integer> minute) {
		this.minute = minute;
	}

	public int getHaustRatio() {
		return haustRatio;
	}

	public void setHaustRatio(int haustRatio) {
		this.haustRatio = haustRatio;
	}

	public int getSpeedArmy() {
		return speedArmy;
	}

	public void setSpeedArmy(int speedArmy) {
		this.speedArmy = speedArmy;
	}

	public int getPoint() {
		return point;
	}

	public void setPoint(int point) {
		this.point = point;
	}

	public List<List<Integer>> getPointPerTime() {
		return pointPerTime;
	}

	public void setPointPerTime(List<List<Integer>> pointPerTime) {
		this.pointPerTime = pointPerTime;
	}

}
