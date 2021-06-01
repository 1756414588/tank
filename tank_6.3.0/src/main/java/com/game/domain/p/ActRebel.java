package com.game.domain.p;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
/**
* @ClassName: ActRebel 
* @Description: 活动叛军全局信息
* @author
 */
public class ActRebel {
	private int lastSecond;//临时变量
	private Map<Integer, ActRebelData> rebel = new HashMap<Integer, ActRebelData>();//临时变量
	private LinkedList<ActRebelRank> rebelRank = new LinkedList<>();
	private Map<Long, ActRebelRank> rebelRankLordIdMap = new HashMap<Long, ActRebelRank>();//临时变量

	public int getLastSecond() {
		return lastSecond;
	}

	public void setLastSecond(int lastSecond) {
		this.lastSecond = lastSecond;
	}

	public Map<Integer, ActRebelData> getRebel() {
		return rebel;
	}

	public void setRebel(Map<Integer, ActRebelData> rebel) {
		this.rebel = rebel;
	}

	public LinkedList<ActRebelRank> getRebelRank() {
		return rebelRank;
	}

	public Map<Long, ActRebelRank> getRebelRankLordIdMap() {
		return rebelRankLordIdMap;
	}
}
