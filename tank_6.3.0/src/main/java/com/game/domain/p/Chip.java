/**   
 * @Title: Chip.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月19日 下午5:40:51    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: Chip
 * @Description: 配件碎片
 * @author ZhangJun
 * @date 2015年8月19日 下午5:40:51
 * 
 */
public class Chip {
	private int chipId;
	private int count;

	public int getChipId() {
		return chipId;
	}

	public void setChipId(int chipId) {
		this.chipId = chipId;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	/**
	 * @param chipId
	 * @param count
	 */
	public Chip(int chipId, int count) {
		super();
		this.chipId = chipId;
		this.count = count;
	}

}
