package com.game.domain.p;

import com.game.pb.CommonPb;
/**
* @ClassName: Portrait 
* @Description: 头像
* @author
 */
public class Portrait {

	private int id;
	private int endTime;
	private boolean foreverHold;

	public Portrait() {
	}

	public Portrait(CommonPb.Portrait e) {
		this.id = e.getId();
		this.endTime = e.getEndTime();
		this.foreverHold = e.getForeverHold();
	}
	
	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
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
