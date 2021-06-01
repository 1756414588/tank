/**   
 * @Title: RefitQue.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月17日 下午4:52:54    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: RefitQue
 * @Description: 改装队列
 * @author ZhangJun
 * @date 2015年8月17日 下午4:52:54
 */
public class RefitQue {
	private int keyId;
	private int tankId;
	private int refitId;
	private int count;
	private int state;
	private int period;
	private int endTime;

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getTankId() {
		return tankId;
	}

	public void setTankId(int tankId) {
		this.tankId = tankId;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public int getState() {
		return state;
	}

	public void setState(int state) {
		this.state = state;
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

	public int getRefitId() {
		return refitId;
	}

	public void setRefitId(int refitId) {
		this.refitId = refitId;
	}

	/**
	 * @param keyId
	 * @param tankId
	 * @param refitId
	 * @param count
	 * @param state
	 * @param period
	 * @param endTime
	 */
	public RefitQue(int keyId, int tankId, int refitId, int count, int state, int period, int endTime) {
		super();
		this.keyId = keyId;
		this.tankId = tankId;
		this.refitId = refitId;
		this.count = count;
		this.state = state;
		this.period = period;
		this.endTime = endTime;
	}

}
