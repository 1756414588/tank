package com.game.domain.s;

import java.util.List;
/**
* @ClassName: StaticActCollegeEducation 
* @Description: s_act_college_education西点学院累积学分表
* @author
 */
public class StaticActCollegeEducation {
	private int id;
	private int minnumber;
	private int maxnumber;
	private List<List<Integer>> fixedbonus;
	private int randomrate;
	private List<List<Integer>> randombonus;
	private List<Integer> cumulativerewards;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getMinnumber() {
		return minnumber;
	}

	public void setMinnumber(int minnumber) {
		this.minnumber = minnumber;
	}

	public int getMaxnumber() {
		return maxnumber;
	}

	public void setMaxnumber(int maxnumber) {
		this.maxnumber = maxnumber;
	}

	public List<List<Integer>> getFixedbonus() {
		return fixedbonus;
	}

	public void setFixedbonus(List<List<Integer>> fixedbonus) {
		this.fixedbonus = fixedbonus;
	}

	public int getRandomrate() {
		return randomrate;
	}

	public void setRandomrate(int randomrate) {
		this.randomrate = randomrate;
	}

	public List<List<Integer>> getRandombonus() {
		return randombonus;
	}

	public void setRandombonus(List<List<Integer>> randombonus) {
		this.randombonus = randombonus;
	}

	public List<Integer> getCumulativerewards() {
		return cumulativerewards;
	}

	public void setCumulativerewards(List<Integer> cumulativerewards) {
		this.cumulativerewards = cumulativerewards;
	}

}
