/**   
 * @Title: StaticPartUp.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月19日 下午5:29:26    
 * @version V1.0   
 */
package com.game.domain.s;

/**
 * @ClassName: StaticPartUp
 * @Description: 配件强化
 * @author ZhangJun
 * @date 2015年8月19日 下午5:29:26
 * 
 */
public class StaticPartUp {
	private int partId;
	private int lv;
	private int prob;
	private int stone;
	private long stoneExplode;

	public int getPartId() {
		return partId;
	}

	public void setPartId(int partId) {
		this.partId = partId;
	}

	public int getLv() {
		return lv;
	}

	public void setLv(int lv) {
		this.lv = lv;
	}

	public int getProb() {
		return prob;
	}

	public void setProb(int prob) {
		this.prob = prob;
	}

	public int getStone() {
		return stone;
	}

	public void setStone(int stone) {
		this.stone = stone;
	}

	public long getStoneExplode() {
		return stoneExplode;
	}

	public void setStoneExplode(long stoneExplode) {
		this.stoneExplode = stoneExplode;
	}

}
