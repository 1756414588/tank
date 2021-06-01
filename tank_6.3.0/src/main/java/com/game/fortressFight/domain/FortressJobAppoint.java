package com.game.fortressFight.domain;

/**
 * 要塞职位任命
 * 
 * @author wanyi
 *
 */
public class FortressJobAppoint {
	private int jobId;
	private int index;
	private long lordId;
	private String nick;
	private int appointTime;
	private int endTime;

	public int getIndex() {
		return index;
	}

	public void setIndex(int index) {
		this.index = index;
	}

	public String getNick() {
		return nick;
	}

	public void setNick(String nick) {
		this.nick = nick;
	}

	public int getJobId() {
		return jobId;
	}

	public void setJobId(int jobId) {
		this.jobId = jobId;
	}

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public int getAppointTime() {
		return appointTime;
	}

	public void setAppointTime(int appointTime) {
		this.appointTime = appointTime;
	}

	public int getEndTime() {
		return endTime;
	}

	public void setEndTime(int endTime) {
		this.endTime = endTime;
	}

}
