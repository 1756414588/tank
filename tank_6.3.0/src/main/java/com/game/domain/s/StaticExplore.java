/**   
 * @Title: StaticExplore.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月31日 下午7:11:25    
 * @version V1.0   
 */
package com.game.domain.s;

import java.util.List;

/**
 * @ClassName: StaticExplore
 * @Description: 探险副本
 * @author ZhangJun
 * @date 2015年8月31日 下午7:11:25
 * 
 */
public class StaticExplore {
	private int exploreId;
	private int type;
	private int exp;
	private List<List<Integer>> drop;
	private List<List<Integer>> dropOne;
	private List<List<Integer>> dropMaterial;
	private List<List<Integer>> form;
	private List<Integer> hero;
	private List<List<Integer>> attr;
	private int preId;
	private int weight;

	public int getExploreId() {
		return exploreId;
	}

	public void setExploreId(int exploreId) {
		this.exploreId = exploreId;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public List<List<Integer>> getDrop() {
		return drop;
	}

	public void setDrop(List<List<Integer>> drop) {
		this.drop = drop;
	}

	public List<List<Integer>> getForm() {
		return form;
	}

	public void setForm(List<List<Integer>> form) {
		this.form = form;
	}

	public List<Integer> getHero() {
		return hero;
	}

	public void setHero(List<Integer> hero) {
		this.hero = hero;
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

	public List<List<Integer>> getDropOne() {
		return dropOne;
	}

	public void setDropOne(List<List<Integer>> dropOne) {
		this.dropOne = dropOne;
	}

	public int getWeight() {
		return weight;
	}

	public void setWeight(int weight) {
		this.weight = weight;
	}

	public List<List<Integer>> getDropMaterial() {
		return dropMaterial;
	}

	public void setDropMaterial(List<List<Integer>> dropMaterial) {
		this.dropMaterial = dropMaterial;
	}

	public int getExp() {
		return exp;
	}

	public void setExp(int exp) {
		this.exp = exp;
	}

}
