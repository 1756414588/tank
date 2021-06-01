package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2016-3-17 下午4:22:10
 * @Description: 配件分解数据
 */

public class PartResolve {
	private int type;
	private int quality;
	private int count;
	
	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getQuality() {
		return quality;
	}

	public void setQuality(int quality) {
		this.quality = quality;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public PartResolve() {
	}

	public PartResolve(int type, int quality, int count) {
		this.type = type;
		this.quality = quality;
		this.count = count;
	}

}
