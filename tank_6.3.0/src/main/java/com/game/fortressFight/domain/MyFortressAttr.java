package com.game.fortressFight.domain;

/**
 * 我的进修效果
 * 
 * @author wanyi
 *
 */
public class MyFortressAttr {
	private int id;
	private int level;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public MyFortressAttr(int id, int level) {
		super();
		this.id = id;
		this.level = level;
	}

	public MyFortressAttr() {
		super();
	}

}
