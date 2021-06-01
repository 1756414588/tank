package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2015-8-27 下午2:07:20
 * @declare
 */
@Deprecated
public class RefineQue {

	private int keyId;
	private int refineId;
	private int period;
	private int endTime;

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getRefineId() {
		return refineId;
	}

	public void setRefineId(int refineId) {
		this.refineId = refineId;
	}

	public int getPeriod() {
		return period;
	}

	public void setPeriod(int period) {
		this.period = period;
	}

	public int getEndTime() {
		return endTime;
	}

	public void setEndTime(int endTime) {
		this.endTime = endTime;
	}

	public RefineQue(int keyId, int refineId, int period, int endTime) {
		this.keyId = keyId;
		this.refineId = refineId;
		this.period = period;
		this.endTime = endTime;
	}

}
