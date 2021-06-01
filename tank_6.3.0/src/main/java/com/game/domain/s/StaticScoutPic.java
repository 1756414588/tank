package com.game.domain.s;

/**
 * @author: LiFeng
 * @date: 2018年9月17日 下午6:56:37
 * @description: 扫矿验证图片分类信息
 */
public class StaticScoutPic {
	private int keyId;
	private int genus; //图片大类
	private int species; //图片小类

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getGenus() {
		return genus;
	}

	public void setGenus(int genus) {
		this.genus = genus;
	}

	public int getSpecies() {
		return species;
	}

	public void setSpecies(int species) {
		this.species = species;
	}

}
