package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-2 下午2:52:32
 * @Description: 祝福
 */

public class Bless {

	private long lordId;
	private int state;
	private int blessTime;

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public int getState() {
		return state;
	}

	public void setState(int state) {
		this.state = state;
	}

	public int getBlessTime() {
		return blessTime;
	}

	public void setBlessTime(int blessTime) {
		this.blessTime = blessTime;
	}

	public Bless() {
	}

	public Bless(long lordId, int blessTime) {
		this.lordId = lordId;
		this.blessTime = blessTime;
	}
}
