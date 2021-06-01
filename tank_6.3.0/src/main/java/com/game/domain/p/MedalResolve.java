package com.game.domain.p;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class MedalResolve {

	private int type;
	private int quality;
	private int count;
	private int position;

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

	public int getPosition() {
		return position;
	}

	public void setPosition(int position) {
		this.position = position;
	}

	public MedalResolve() {
	}

	public MedalResolve(int type, int quality, int count, int position) {
		this.type = type;
		this.quality = quality;
		this.count = count;
		this.position = position;
	}

}
