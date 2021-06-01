package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-18 下午5:10:38
 * @Description: 军团大关卡
 */

public class PartySection {

	private int sectionId;
	private int combatLive;
	private int status;

	public int getSectionId() {
		return sectionId;
	}

	public void setSectionId(int sectionId) {
		this.sectionId = sectionId;
	}

	public int getCombatLive() {
		return combatLive;
	}

	public void setCombatLive(int combatLive) {
		this.combatLive = combatLive;
	}

	public int getStatus() {
		return status;
	}

	public void setStatus(int status) {
		this.status = status;
	}

}
