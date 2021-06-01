/**   
 * @Title: WarLog.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年12月15日 下午5:43:15    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: WarLog
 * @Description: 百团战日志
 * @author ZhangJun
 * @date 2015年12月15日 下午5:43:15
 * 
 */
public class WarLog {
	private int keyId;
	private int warTime;
	private int state;
	private int partyCount;

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getWarTime() {
		return warTime;
	}

	public void setWarTime(int warTime) {
		this.warTime = warTime;
	}

	public int getState() {
		return state;
	}

	public void setState(int state) {
		this.state = state;
	}

	public int getPartyCount() {
		return partyCount;
	}

	public void setPartyCount(int partyCount) {
		this.partyCount = partyCount;
	}

}
