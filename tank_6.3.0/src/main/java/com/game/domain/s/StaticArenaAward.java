/**   
 * @Title: StaticArenaAward.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月9日 下午4:19:11    
 * @version V1.0   
 */
package com.game.domain.s;

import java.util.List;

/**
 * @ClassName: StaticArenaAward
 * @Description: 竞技场排名奖励
 * @author ZhangJun
 * @date 2015年9月9日 下午4:19:11
 * 
 */
public class StaticArenaAward {
	private int keyId;
	private int beginRank;
	private int endRank;
	private List<List<Integer>> award;
	private int score;

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getBeginRank() {
		return beginRank;
	}

	public void setBeginRank(int beginRank) {
		this.beginRank = beginRank;
	}

	public int getEndRank() {
		return endRank;
	}

	public void setEndRank(int endRank) {
		this.endRank = endRank;
	}

	public List<List<Integer>> getAward() {
		return award;
	}

	public void setAward(List<List<Integer>> award) {
		this.award = award;
	}

	public int getScore() {
		return score;
	}

	public void setScore(int score) {
		this.score = score;
	}

}
