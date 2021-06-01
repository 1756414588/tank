package com.game.domain.s;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-18 下午3:41:54
 * @declare 军团关卡
 */

public class StaticPartyCombat {

	private int combatId;
	private int sectionId;
	private String name;
	private int exp;
	private int contribute;
	private List<List<Integer>> drop;
	private List<List<Integer>> lastAward;
	private List<List<Integer>> form;
	private List<List<Integer>> attr;
	private List<List<Integer>> box;
	private int totalTank;

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

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getExp() {
		return exp;
	}

	public void setExp(int exp) {
		this.exp = exp;
	}

	public int getContribute() {
		return contribute;
	}

	public void setContribute(int contribute) {
		this.contribute = contribute;
	}

	public List<List<Integer>> getDrop() {
		return drop;
	}

	public void setDrop(List<List<Integer>> drop) {
		this.drop = drop;
	}

	public List<List<Integer>> getLastAward() {
		return lastAward;
	}

	public void setLastAward(List<List<Integer>> lastAward) {
		this.lastAward = lastAward;
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

	public List<List<Integer>> getBox() {
		return box;
	}

	public void setBox(List<List<Integer>> box) {
		this.box = box;
	}

	public int getTotalTank() {
		return totalTank;
	}

	public void setTotalTank(int totalTank) {
		this.totalTank = totalTank;
	}

}
