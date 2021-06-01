/**   
 * @Title: StaticCombat.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月28日 下午12:00:58    
 * @version V1.0   
 */
package com.game.domain.s;

import java.util.List;

/**
 * @ClassName: StaticCombat
 * @Description: 关卡配置
 * @author ZhangJun
 * @date 2015年8月28日 下午12:00:58
 * 
 */
public class StaticCombat {
	private int combatId;
	private int sectionId;
	private int exp;
	private List<List<Integer>> drop;
	private List<List<Integer>> firstAward;
	private List<List<Integer>> form;
	private List<Integer> hero;
	private List<List<Integer>> attr;
	private int preId;		//前置关卡ID

	public int getCombatId() {
		return combatId;
	}

	public void setCombatId(int combatId) {
		this.combatId = combatId;
	}

	public int getSectionId() {
		return sectionId;
	}

	public void setSectionId(int sectionId) {
		this.sectionId = sectionId;
	}

	public int getExp() {
		return exp;
	}

	public void setExp(int exp) {
		this.exp = exp;
	}

	public List<List<Integer>> getDrop() {
		return drop;
	}

	public void setDrop(List<List<Integer>> drop) {
		this.drop = drop;
	}

	public List<List<Integer>> getFirstAward() {
		return firstAward;
	}

	public void setFirstAward(List<List<Integer>> firstAward) {
		this.firstAward = firstAward;
	}

	public List<List<Integer>> getForm() {
		return form;
	}

	public void setForm(List<List<Integer>> form) {
		this.form = form;
	}



	public List<List<Integer>> getAttr() {
		return attr;
	}

	public void setAttr(List<List<Integer>> attr) {
		this.attr = attr;
	}

	public int getPreId() {
		return preId;
	}

	public void setPreId(int preId) {
		this.preId = preId;
	}

	public List<Integer> getHero() {
		return hero;
	}

	public void setHero(List<Integer> hero) {
		this.hero = hero;
	}

}
