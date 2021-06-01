package com.game.domain.p;

import com.game.pb.CommonPb;
/**
* @ClassName: Pendant 
* @Description: 挂件
* @author
 */
public class Pendant {

	private int pendantId;
	private int endTime;
	private boolean foreverHold;

	public Pendant() {
	}

	public Pendant(CommonPb.Pendant e) {
		this.pendantId = e.getPendantId();
		this.endTime = e.getEndTime();
		this.foreverHold = e.getForeverHold();
	}

	public int getPendantId() {
		return pendantId;
	}

	public void setPendantId(int pendantId) {
		this.pendantId = pendantId;
	}

	public int getEndTime() {
		return endTime;
	}

	public void setEndTime(int endTime) {
		this.endTime = endTime;
	}

	public boolean isForeverHold() {
		return foreverHold;
	}

	public void setForeverHold(boolean foreverHold) {
		this.foreverHold = foreverHold;
	}
}
