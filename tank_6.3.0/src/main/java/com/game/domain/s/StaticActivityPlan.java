package com.game.domain.s;

import java.util.Date;

/**
 * @author ChenKui
 * @version 创建时间：2015-12-18 下午2:47:32
 * @declare 活动计划表
 */

public class StaticActivityPlan {

	private int keyId;
	private int moldId;
	private int awardId;
	private int activityId;
	private int openBegin;
	private int openDuration;
	private int displayDuration;

	private Date beginTime;
	private Date endTime;
	private Date displayTime;

	private int plat;
	private int serverBegin;
	private int serverEnd;

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getMoldId() {
		return moldId;
	}

	public void setMoldId(int moldId) {
		this.moldId = moldId;
	}

	public int getAwardId() {
		return awardId;
	}

	public void setAwardId(int awardId) {
		this.awardId = awardId;
	}

	public int getActivityId() {
		return activityId;
	}

	public void setActivityId(int activityId) {
		this.activityId = activityId;
	}

	public int getOpenBegin() {
		return openBegin;
	}

	public void setOpenBegin(int openBegin) {
		this.openBegin = openBegin;
	}

	public int getOpenDuration() {
		return openDuration;
	}

	public void setOpenDuration(int openDuration) {
		this.openDuration = openDuration;
	}

	public int getDisplayDuration() {
		return displayDuration;
	}

	public void setDisplayDuration(int displayDuration) {
		this.displayDuration = displayDuration;
	}

	public Date getBeginTime() {
		return beginTime;
	}

	public void setBeginTime(Date beginTime) {
		this.beginTime = beginTime;
	}

	public Date getEndTime() {
		return endTime;
	}

	public void setEndTime(Date endTime) {
		this.endTime = endTime;
	}

	public Date getDisplayTime() {
		return displayTime;
	}

	public void setDisplayTime(Date displayTime) {
		this.displayTime = displayTime;
	}

	public int getPlat() {
		return plat;
	}

	public void setPlat(int plat) {
		this.plat = plat;
	}

	public int getServerBegin() {
		return serverBegin;
	}

	public void setServerBegin(int serverBegin) {
		this.serverBegin = serverBegin;
	}

	public int getServerEnd() {
		return serverEnd;
	}

	public void setServerEnd(int serverEnd) {
		this.serverEnd = serverEnd;
	}

}
