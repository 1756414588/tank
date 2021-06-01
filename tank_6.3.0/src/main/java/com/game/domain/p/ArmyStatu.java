/**   
 * @Title: ArmyState.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年10月22日 下午6:04:58    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: ArmyState
 * @Description: 部队状态
 * @author ZhangJun
 * @date 2015年10月22日 下午6:04:58
 * 
 */
public class ArmyStatu {
	private long lordId;
	private int keyId;
	private int state;

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getState() {
		return state;
	}

	public void setState(int state) {
		this.state = state;
	}

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	/**
	 * @param lordId
	 * @param keyId
	 * @param state
	 */
	public ArmyStatu(long lordId, int keyId, int state) {
		super();
		this.lordId = lordId;
		this.keyId = keyId;
		this.state = state;
	}

}
