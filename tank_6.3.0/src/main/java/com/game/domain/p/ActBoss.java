package com.game.domain.p;

import java.util.HashSet;
import java.util.Set;
/**
* @ClassName: ActBoss 
* @Description: 活动boss
* @author
 */
public class ActBoss {
	private int state;// 0未召唤 1已召唤
	private int endTime;
	private int bossBagNum;
	private int callTimes;
	private long lordId;// 召唤人id
	private String bossName = "";
	private int bossIcon;
	private Set<Long> joinLordIds = new HashSet<>();

	public int getState() {
		return state;
	}

	public void setState(int state) {
		this.state = state;
	}

	public int getEndTime() {
		return endTime;
	}

	public void setEndTime(int endTime) {
		this.endTime = endTime;
	}

	public int getBossBagNum() {
		return bossBagNum;
	}

	public void setBossBagNum(int bossBagNum) {
		this.bossBagNum = bossBagNum;
	}

	public int getCallTimes() {
		return callTimes;
	}

	public void setCallTimes(int callTimes) {
		this.callTimes = callTimes;
	}

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public String getBossName() {
		return bossName;
	}

	public void setBossName(String bossName) {
		this.bossName = bossName;
	}

	public int getBossIcon() {
		return bossIcon;
	}

	public void setBossIcon(int bossIcon) {
		this.bossIcon = bossIcon;
	}

	public Set<Long> getJoinLordIds() {
		return joinLordIds;
	}

	public void setJoinLordIds(Set<Long> joinLordIds) {
		this.joinLordIds = joinLordIds;
	}
}
