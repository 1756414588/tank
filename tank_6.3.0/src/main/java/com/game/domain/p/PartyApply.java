package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-11 上午10:16:06
 * @Description: 加入军团申请
 */

public class PartyApply {

	private long lordId;
	private int applyDate;

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public void setApplyDate(int applyDate) {
		this.applyDate = applyDate;
	}

	public int getApplyDate() {
		return applyDate;
	}

	public PartyApply() {
	}

	public PartyApply(long lordId, int today) {
		this.lordId = lordId;
		this.applyDate = today;
	}

}
