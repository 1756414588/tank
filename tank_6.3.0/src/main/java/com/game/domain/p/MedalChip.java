package com.game.domain.p;

/**
* @ClassName: MedalChip 
* @Description: 勋章碎片 用来合成勋章
* @author
 */
public class MedalChip {
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

	public MedalChip(int chipId, int count) {
		this.chipId = chipId;
		this.count = count;
	}
}
