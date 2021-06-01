/**   
 * @Title: StaticProsLv.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月13日 上午11:05:38    
 * @version V1.0   
 */
package com.game.domain.s;

/**
 * @ClassName: StaticLordPros
 * @Description: 繁荣度等级
 * @author ZhangJun
 * @date 2015年8月13日 上午11:05:38
 * 
 */
public class StaticLordPros {
	private int prosLv;
	private int prosExp;
	private int tankCount;
	private int staffingAdd;

	public int getProsLv() {
		return prosLv;
	}

	public void setProsLv(int prosLv) {
		this.prosLv = prosLv;
	}

	public int getProsExp() {
		return prosExp;
	}

	public void setProsExp(int prosExp) {
		this.prosExp = prosExp;
	}

	public int getTankCount() {
		return tankCount;
	}

	public void setTankCount(int tankCount) {
		this.tankCount = tankCount;
	}

	public int getStaffingAdd() {
		return staffingAdd;
	}

	public void setStaffingAdd(int staffingAdd) {
		this.staffingAdd = staffingAdd;
	}

}
