package com.game.domain.s;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2015-12-28 下午15:23:23
 * @declare 天天充值配置表
 */

public class StaticActEverydayPay {

	private int everydayId;
	private int dayiy;
	private int box1;
	private int box2;
	private int box3;
	private List<List<Integer>> specialList;

	public int getEverydayId() {
		return everydayId;
	}

	public void setEverydayId(int everydayId) {
		this.everydayId = everydayId;
	}

	public int getDayiy() {
		return dayiy;
	}

	public void setDayiy(int dayiy) {
		this.dayiy = dayiy;
	}

	public int getBox1() {
		return box1;
	}

	public void setBox1(int box1) {
		this.box1 = box1;
	}

	public int getBox2() {
		return box2;
	}

	public void setBox2(int box2) {
		this.box2 = box2;
	}

	public int getBox3() {
		return box3;
	}

	public void setBox3(int box3) {
		this.box3 = box3;
	}

	public List<List<Integer>> getSpecialList() {
		return specialList;
	}

	public void setSpecialList(List<List<Integer>> specialList) {
		this.specialList = specialList;
	}

}
