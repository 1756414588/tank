package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2015-8-28 下午3:25:02
 * @Description: 军团科技
 */

public class PartyScience {

	private int scienceId;
	private int scienceLv;
	private int schedule;

	public int getScienceId() {
		return scienceId;
	}

	public void setScienceId(int scienceId) {
		this.scienceId = scienceId;
	}

	public int getScienceLv() {
		return scienceLv;
	}

	public void setScienceLv(int scienceLv) {
		this.scienceLv = scienceLv;
	}

	public int getSchedule() {
		return schedule;
	}

	public void setSchedule(int schedule) {
		this.schedule = schedule;
	}

	public PartyScience() {
	}

	public PartyScience(int scienceId, int scienceLv) {
		this.scienceId = scienceId;
		this.scienceLv = scienceLv;
	}

}
