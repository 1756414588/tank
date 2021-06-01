package com.game.domain.s;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class StaticHonourBuff {

	private int phase;

	private int scoreup;
	
	private int resourceup;

	// buff类型，1为增益，-1为减益
	private int type;

	// 属性值buff
	private List<List<Integer>> attr = new ArrayList<>();

	// 损兵
	private int deathtank;

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getPhase() {
		return phase;
	}

	public void setPhase(int phase) {
		this.phase = phase;
	}

	public int getScoreup() {
		return scoreup;
	}

	public void setScoreup(int scoreup) {
		this.scoreup = scoreup;
	}

	public List<List<Integer>> getAttr() {
		return attr;
	}

	public void setAttr(List<List<Integer>> attr) {
		this.attr = attr;
	}

	public int getDeathtank() {
		return deathtank;
	}

	public void setDeathtank(int deathtank) {
		this.deathtank = deathtank;
	}
	
	public int getResourceup() {
		return resourceup;
	}

	public void setResourceup(int resourceup) {
		this.resourceup = resourceup;
	}

	public Map<Integer, Integer> getAttrBuff() {
		Map<Integer, Integer> buff = new HashMap<>();
		for (List<Integer> list : attr) {
			if (list.size() < 2) {
				continue;
			}
			buff.put(list.get(0), list.get(1));
		}
		return buff;
	}

}
