package com.game.domain.s;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-10 下午1:54:38
 * @declare 军团建筑升级系数
 */

public class StaticPartyBuildLevel {

	private int type;
	private int buildLv;
	private int needExp;

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getBuildLv() {
		return buildLv;
	}

	public void setBuildLv(int buildLv) {
		this.buildLv = buildLv;
	}

	public int getNeedExp() {
		return needExp;
	}

	public void setNeedExp(int needExp) {
		this.needExp = needExp;
	}

}
