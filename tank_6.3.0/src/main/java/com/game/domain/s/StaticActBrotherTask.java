package com.game.domain.s;

import java.util.List;

/**
 * @ClassName:StaticActBrotherTask
 * @author zc
 * @Description: 对应s_act_brother_task表
 * @date 2017年9月11日
 */
public class StaticActBrotherTask {
	private int id;
	private int type;// 攻打飞艇次数；2=成功占领飞艇次数
	private int number;// 次数
	private List<List<Integer>> awards;// 奖励内容

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getNumber() {
		return number;
	}

	public void setNumber(int number) {
		this.number = number;
	}

	public List<List<Integer>> getAwards() {
		return awards;
	}

	public void setAwards(List<List<Integer>> awards) {
		this.awards = awards;
	}
}
