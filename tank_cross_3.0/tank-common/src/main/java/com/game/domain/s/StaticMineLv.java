/**   
 * @Title: StaticMineLv.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月15日 下午2:22:02    
 * @version V1.0   
 */
package com.game.domain.s;

/**
 * @ClassName: StaticMineLv
 * @Description: 矿点升级系数
 * @author ZhangJun
 * @date 2015年9月15日 下午2:22:02
 * 
 */
public class StaticMineLv {
	private int lv;
	private int type;
	private int production;
	private int exp;
	private int staffingExp;
	private int honourLiveScore;
	private int honourLiveGold;
	private int heroGold;

	public int getHeroGold() {
		return heroGold;
	}

	public void setHeroGold(int heroGold) {
		this.heroGold = heroGold;
	}

	public int getLv() {
		return lv;
	}

	public void setLv(int lv) {
		this.lv = lv;
	}

	public int getProduction() {
		return production;
	}

	public void setProduction(int production) {
		this.production = production;
	}

	public int getExp() {
		return exp;
	}

	public void setExp(int exp) {
		this.exp = exp;
	}

	public int getStaffingExp() {
		return staffingExp;
	}

	public void setStaffingExp(int staffingExp) {
		this.staffingExp = staffingExp;
	}

	public int getHonourLiveScore() {
		return honourLiveScore;
	}

	public void setHonourLiveScore(int honourLiveScore) {
		this.honourLiveScore = honourLiveScore;
	}

	public int getHonourLiveGold() {
		return honourLiveGold;
	}

	public void setHonourLiveGold(int honourLiveGold) {
		this.honourLiveGold = honourLiveGold;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}
}
