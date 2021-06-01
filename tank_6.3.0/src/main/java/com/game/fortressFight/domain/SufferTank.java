/**   
 * @Title: SufferTank.java    
 * @Package com.game.fortressFight.domain    
 * @Description:   
 * @author WanYi  
 * @date 2016年6月8日 下午4:32:33    
 * @version V1.0   
 */
package com.game.fortressFight.domain;

/**
 * @ClassName: SufferTank
 * @Description: 损失的坦克
 * @author WanYi
 * @date 2016年6月8日 下午4:32:33
 * 
 */
public class SufferTank {
	private int tankId;
	private int sufferCount;

	public int getTankId() {
		return tankId;
	}

	public void setTankId(int tankId) {
		this.tankId = tankId;
	}

	public int getSufferCount() {
		return sufferCount;
	}

	public void setSufferCount(int sufferCount) {
		this.sufferCount = sufferCount;
	}

	/**
	 * @param tankId
	 * @param sufferCount
	 */
	public SufferTank(int tankId, int sufferCount) {
		super();
		this.tankId = tankId;
		this.sufferCount = sufferCount;
	}

	/**      
	*     
	*/
	public SufferTank() {
		super();
	}

}
