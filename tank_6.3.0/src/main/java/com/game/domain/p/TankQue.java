/**   
 * @Title: TankQue.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月11日 下午3:12:05    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: TankQue
 * @Description: 坦克生产
 * @author ZhangJun
 * @date 2015年8月11日 下午3:12:05
 * 
 */
public class TankQue {
	private int keyId;
	private int tankId;
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

	public int getEndTime() {
		return endTime;
	}

	public void setEndTime(int endTime) {
		this.endTime = endTime;
	}

	public int getPeriod() {
		return period;
	}

	public void setPeriod(int period) {
		this.period = period;
	}

	/**      
	* @param keyId
	* @param tankId
	* @param count
	* @param state
	* @param period
	* @param endTime    
	*/
	public TankQue(int keyId, int tankId, int count, int state, int period, int endTime) {
		super();
		this.keyId = keyId;
		this.tankId = tankId;
		this.count = count;
		this.state = state;
		this.period = period;
		this.endTime = endTime;
	}

	
}
