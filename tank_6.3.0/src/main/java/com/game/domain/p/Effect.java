/**   
 * @Title: Effect.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月6日 下午2:54:08    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: Effect
 * @Description: buff状态
 * @author ZhangJun
 * @date 2015年9月6日 下午2:54:08
 * 
 */
public class Effect {
	private int effectId;
	private int endTime; // 结束时间， 若为0表示是永久buff
	private int value; // buff数值， 若为0表示是可通过effectId确定value的固定值buff

	public int getEffectId() {
		return effectId;
	}

	public void setEffectId(int effectId) {
		this.effectId = effectId;
	}

	public int getEndTime() {
		return endTime;
	}

	public void setEndTime(int endTime) {
		this.endTime = endTime;
	}

	public int getValue() {
		return value;
	}

	public void setValue(int value) {
		this.value = value;
	}

	/**
	 * @param effectId
	 * @param endTime
	 */
	public Effect(int effectId, int endTime) {
		super();
		this.effectId = effectId;
		this.endTime = endTime;
	}

	public Effect(int effectId, int endTime, int value) {
		super();
		this.effectId = effectId;
		this.endTime = endTime;
		this.value = value;
	}

}
