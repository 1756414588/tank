package com.game.fortressFight.domain;

import java.util.HashMap;
import java.util.Map;

/**
 * 要塞战军团统计
 * 
 * @author wanyi
 */
public class MyPartyStatistics {
	private int partyId;
	private int fightNum = 0;
	private int jifen = 0;
	private int winNum = 0;
	private boolean isAttack = false;
	// 摧毁对方的坦克
	private Map<Integer, SufferTank> destoryTankMap = new HashMap<Integer, SufferTank>();

	public int getPartyId() {
		return partyId;
	}

	public void setPartyId(int partyId) {
		this.partyId = partyId;
	}

	public int getFightNum() {
		return fightNum;
	}

	public void setFightNum(int fightNum) {
		this.fightNum = fightNum;
	}

	public int getJifen() {
		return jifen;
	}

	public void setJifen(int jifen) {
		this.jifen = jifen;
	}

	public Map<Integer, SufferTank> getDestoryTankMap() {
		return destoryTankMap;
	}

	public void setDestoryTankMap(Map<Integer, SufferTank> destoryTankMap) {
		this.destoryTankMap = destoryTankMap;
	}

	public int getWinNum() {
		return winNum;
	}

	public void setWinNum(int winNum) {
		this.winNum = winNum;
	}

	public boolean isAttack() {
		return isAttack;
	}

	public void setAttack(boolean isAttack) {
		this.isAttack = isAttack;
	}

	@Override
	public String toString() {
		return "MyPartyStatistics [partyId=" + partyId + ", fightNum=" + fightNum + ", jifen=" + jifen + ", winNum="
				+ winNum + ", isAttack=" + isAttack + ", destoryTankMap=" + destoryTankMap + "]";
	}
	
	
}
