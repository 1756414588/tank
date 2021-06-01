/**   
 * @Title: PropQue.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月14日 下午5:01:59    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: PropQue
 * @Description: 道具生产
 * @author ZhangJun
 * @date 2015年8月14日 下午5:01:59
 * 
 */
public class PropQue {
	private int keyId;
	private int propId;
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

	public int getPropId() {
		return propId;
	}

	public void setPropId(int propId) {
		this.propId = propId;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public int getEndTime() {
		return endTime;
	}

	public void setEndTime(int endTime) {
		this.endTime = endTime;
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

	/**
	 * @param keyId
	 * @param propId
	 * @param count
	 * @param state
	 * @param period
	 * @param endTime
	 */
	public PropQue(int keyId, int propId, int count, int state, int period, int endTime) {
		super();
		this.keyId = keyId;
		this.propId = propId;
		this.count = count;
		this.state = state;
		this.period = period;
		this.endTime = endTime;
	}

	/**      
	*     
	*/
	public PropQue() {
		super();
	}

	
}
