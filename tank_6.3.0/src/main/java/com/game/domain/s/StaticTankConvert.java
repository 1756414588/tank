package com.game.domain.s;

import java.util.List;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class StaticTankConvert {

	private int id;
	private int tankId;
	private List<Integer> convertType;
	private List<List<Integer>> convertPrice;
	private int awardId;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getTankId() {
		return tankId;
	}

	public void setTankId(int tankId) {
		this.tankId = tankId;
	}

	public List<Integer> getConvertType() {
		return convertType;
	}

	public void setConvertType(List<Integer> convertType) {
		this.convertType = convertType;
	}

	public List<List<Integer>> getConvertPrice() {
		return convertPrice;
	}

	public void setConvertPrice(List<List<Integer>> convertPrice) {
		this.convertPrice = convertPrice;
	}

	public int getAwardId() {
		return awardId;
	}

	public void setAwardId(int awardId) {
		this.awardId = awardId;
	}

}
