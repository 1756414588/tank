/**   
 * @Title: Boss.java    
 * @Package com.game.bossFight.domain    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年12月30日 下午1:58:26    
 * @version V1.0   
 */
package com.game.bossFight.domain;

/**
 * @ClassName: Boss
 * @Description: 祭坛boss
 * @author ZhangJun
 * @date 2015年12月30日 下午1:58:26
 * 
 */
public class Boss {
	private int bossCreateTime;
	private int bossLv;
	private int bossHp;
	private int bossWhich;//第几管血
	private int bossState;
	private long hurt;
	private int bossType;// BOSS类型， 1 世界BOSS，2 祭坛BOSS
	
	private int partyId;// 该值用来记录祭坛BOSS所属的军团
	private int nextStateTime;// 进入下一阶段状态的时间，毫秒数/1000

	public int getBossCreateTime() {
		return bossCreateTime;
	}

	public void setBossCreateTime(int bossCreateTime) {
		this.bossCreateTime = bossCreateTime;
	}

	public int getBossLv() {
		return bossLv;
	}

	public void setBossLv(int bossLv) {
		this.bossLv = bossLv;
	}

	public int getBossHp() {
		return bossHp;
	}

	public void setBossHp(int bossHp) {
		this.bossHp = bossHp;
	}

	public int getBossWhich() {
		return bossWhich;
	}

	public void setBossWhich(int bossWhich) {
		this.bossWhich = bossWhich;
	}

	public int getBossState() {
		return bossState;
	}

	public void setBossState(int bossState) {
		this.bossState = bossState;
	}

	public long getHurt() {
		return hurt;
	}

	public void setHurt(long hurt) {
		this.hurt = hurt;
	}

	public int getBossType() {
		return bossType;
	}

	public void setBossType(int bossType) {
		this.bossType = bossType;
	}

	public int getPartyId() {
		return partyId;
	}

	public void setPartyId(int partyId) {
		this.partyId = partyId;
	}

	public int getNextStateTime() {
		return nextStateTime;
	}

	public void setNextStateTime(int nextStateTime) {
		this.nextStateTime = nextStateTime;
	}

	@Override
	public String toString() {
		return "Boss [bossCreateTime=" + bossCreateTime + ", bossLv=" + bossLv + ", bossHp=" + bossHp + ", bossWhich="
				+ bossWhich + ", bossState=" + bossState + ", hurt=" + hurt + ", bossType=" + bossType + ", partyId="
				+ partyId + ", nextStateTime=" + nextStateTime + "]";
	}

}
