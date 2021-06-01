package com.game.domain.s;

import java.util.List;
/**
* @ClassName: StaticAirship 
* @Description: 飞艇信息表
* @author
 */
public class StaticAirship {
	private int id;
	private int pos;
	private int level;
	private List<Integer> army;
	private List<Integer> openTime;
	private int efficiency;
	private int capacity;
	private int partyLevel;
	private List<List<Integer>> award;
	private List<List<Integer>> cost;
    private List<List<Integer>> repair;
    private List<List<Integer>> spyCost;

    private int fight;//飞艇默认战力

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getPos() {
		return pos;
	}

	public void setPos(int pos) {
		this.pos = pos;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public List<Integer> getArmy() {
		return army;
	}

	public void setArmy(List<Integer> army) {
		this.army = army;
	}

	public List<Integer> getOpenTime() {
		return openTime;
	}

	public void setOpenTime(List<Integer> openTime) {
		this.openTime = openTime;
	}

	public int getEfficiency() {
		return efficiency;
	}

	public void setEfficiency(int efficiency) {
		this.efficiency = efficiency;
	}

	public int getCapacity() {
		return capacity;
	}

	public void setCapacity(int capacity) {
		this.capacity = capacity;
	}

	public List<List<Integer>> getAward() {
		return award;
	}

	public void setAward(List<List<Integer>> award) {
		this.award = award;
	}

    public List<List<Integer>> getRepair() {
        return repair;
    }

    public void setRepair(List<List<Integer>> repair) {
        this.repair = repair;
    }

    public List<List<Integer>> getSpyCost() {
        return spyCost;
    }

    public void setSpyCost(List<List<Integer>> spyCost) {
        this.spyCost = spyCost;
    }

    public int getFight() {
        return fight;
    }

    public void setFight(int fight) {
        this.fight = fight;
    }

    public List<List<Integer>> getCost() {
        return cost;
    }

    public void setCost(List<List<Integer>> cost) {
        this.cost = cost;
    }

	public int getPartyLevel() {
		return partyLevel;
	}

	public void setPartyLevel(int partyLevel) {
		this.partyLevel = partyLevel;
	}
}
