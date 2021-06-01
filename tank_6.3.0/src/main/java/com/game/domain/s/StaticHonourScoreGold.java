package com.game.domain.s;

import java.util.ArrayList;
import java.util.List;

/**
 * @author: LiFeng
 * @date: 2018年8月21日 上午6:38:51
 * @description:
 */
public class StaticHonourScoreGold {

	private int id;
	private int score1;
	private int score2;
	private List<Integer> goldreward = new ArrayList<>();

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getScore1() {
		return score1;
	}

	public void setScore1(int score1) {
		this.score1 = score1;
	}

	public int getScore2() {
		return score2;
	}

	public void setScore2(int score2) {
		this.score2 = score2;
	}

	public List<Integer> getGoldreward() {
		return goldreward;
	}

	public void setGoldreward(List<Integer> goldreward) {
		this.goldreward = goldreward;
	}

	
}
