package com.game.domain.s;

import java.util.List;

/**
* @ClassName: StaticActPirate 
* @Description: 海贼宝藏抽奖活动
* @author
 */
public class StaticActPirate {
	
	private int keyId;
	private int awardId;
	private int id;
	private List<List<Integer>> award;     //  奖励权重
	
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

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public List<List<Integer>> getAward() {
		return award;
	}

	public void setAward(List<List<Integer>> award) {
		this.award = award;
	}


}
