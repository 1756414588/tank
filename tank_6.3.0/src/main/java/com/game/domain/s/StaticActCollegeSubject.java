package com.game.domain.s;

import java.util.List;
/**
* @ClassName: StaticActCollegeSubject 
* @Description: s_act_college_subject 西点学院学科
* @author
 */
public class StaticActCollegeSubject {
	private int id;
	private List<Integer> needbook;
	private int credits;
	private List<List<Integer>> awards;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public List<Integer> getNeedbook() {
		return needbook;
	}

	public void setNeedbook(List<Integer> needbook) {
		this.needbook = needbook;
	}

	public int getCredits() {
		return credits;
	}

	public void setCredits(int credits) {
		this.credits = credits;
	}

	public List<List<Integer>> getAwards() {
		return awards;
	}

	public void setAwards(List<List<Integer>> awards) {
		this.awards = awards;
	}

}
