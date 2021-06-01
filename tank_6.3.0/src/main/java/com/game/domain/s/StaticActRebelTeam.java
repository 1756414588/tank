package com.game.domain.s;

import java.util.List;
/**
* @ClassName: StaticActRebelTeam 
* @Description: 活动叛军编队
* @author
 */
public class StaticActRebelTeam {
	private int rebelId;// 敌军ID
	private String name;//名字
	private int level;// 等级
	private int fight;// 战斗力
	private int team1Id;// 部队1ID
	private int team1number;// 部队1数量
	private int team2Id;// 部队2ID
	private int team2number;// 部队2数量
	private int team3Id;// 部队3ID
	private int team3number;// 部队3数量
	private int team4Id;// 部队4ID
	private int team4number;// 部队4数量
	private int team5Id;//
	private int team5number;//
	private int team6Id;// 部队6ID
	private int team6number;// 部队6数量
	private int exp;// 战斗经验
	private List<List<Integer>> drop;// 道具掉落（备用）

	public int getRebelId() {
		return rebelId;
	}

	public void setRebelId(int rebelId) {
		this.rebelId = rebelId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public int getFight() {
		return fight;
	}

	public void setFight(int fight) {
		this.fight = fight;
	}

	public int getTeam1Id() {
		return team1Id;
	}

	public void setTeam1Id(int team1Id) {
		this.team1Id = team1Id;
	}

	public int getTeam1number() {
		return team1number;
	}

	public void setTeam1number(int team1number) {
		this.team1number = team1number;
	}

	public int getTeam2Id() {
		return team2Id;
	}

	public void setTeam2Id(int team2Id) {
		this.team2Id = team2Id;
	}

	public int getTeam2number() {
		return team2number;
	}

	public void setTeam2number(int team2number) {
		this.team2number = team2number;
	}

	public int getTeam3Id() {
		return team3Id;
	}

	public void setTeam3Id(int team3Id) {
		this.team3Id = team3Id;
	}

	public int getTeam3number() {
		return team3number;
	}

	public void setTeam3number(int team3number) {
		this.team3number = team3number;
	}

	public int getTeam4Id() {
		return team4Id;
	}

	public void setTeam4Id(int team4Id) {
		this.team4Id = team4Id;
	}

	public int getTeam4number() {
		return team4number;
	}

	public void setTeam4number(int team4number) {
		this.team4number = team4number;
	}

	public int getTeam5Id() {
		return team5Id;
	}

	public void setTeam5Id(int team5Id) {
		this.team5Id = team5Id;
	}

	public int getTeam5number() {
		return team5number;
	}

	public void setTeam5number(int team5number) {
		this.team5number = team5number;
	}

	public int getTeam6Id() {
		return team6Id;
	}

	public void setTeam6Id(int team6Id) {
		this.team6Id = team6Id;
	}

	public int getTeam6number() {
		return team6number;
	}

	public void setTeam6number(int team6number) {
		this.team6number = team6number;
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

	@Override
	public String toString() {
		return "StaticRebelTeam [rebelId=" + rebelId  + ", level=" + level + ", fight=" + fight
				+ ", team1Id=" + team1Id + ", team1number=" + team1number + ", team2Id=" + team2Id + ", team2number="
				+ team2number + ", team3Id=" + team3Id + ", team3number=" + team3number + ", team4Id=" + team4Id
				+ ", team4number=" + team4number + ", team5Id=" + team5Id + ", team5number=" + team5number
				+ ", team6Id=" + team6Id + ", team6number=" + team6number + ", exp=" + exp + ", drop=" + drop + "]";
	}
}
