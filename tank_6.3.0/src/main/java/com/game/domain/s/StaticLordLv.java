/**   
 * @Title: StaticLordLv.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月13日 上午11:03:20    
 * @version V1.0   
 */
package com.game.domain.s;

/**
 * @ClassName: StaticLordLv
 * @Description: 角色升级系数配置
 * @author ZhangJun
 * @date 2015年8月13日 上午11:03:20
 * 
 */
public class StaticLordLv {
	private int lordLv;
	private long needExp;
	private int tankCount;
	private int blessExp;
	private int winPros;

	public int getLordLv() {
		return lordLv;
	}

	public void setLordLv(int lordLv) {
		this.lordLv = lordLv;
	}

	public long getNeedExp() {
		return needExp;
	}

	public void setNeedExp(long needExp) {
		this.needExp = needExp;
	}

	public int getTankCount() {
		return tankCount;
	}

	public void setTankCount(int tankCount) {
		this.tankCount = tankCount;
	}

	public int getBlessExp() {
		return blessExp;
	}

	public void setBlessExp(int blessExp) {
		this.blessExp = blessExp;
	}

	public int getWinPros() {
		return winPros;
	}

	public void setWinPros(int winPros) {
		this.winPros = winPros;
	}

}
