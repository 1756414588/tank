package com.game.domain.p;

/**
 * 失败的次数
 * 
 * @author wanyi
 *
 */
public class FailNum {
	private int operType;// 操作类型 1.升级统率 2.其他
	private int num;

	public int getOperType() {
		return operType;
	}

	public void setOperType(int operType) {
		this.operType = operType;
	}

	public int getNum() {
		return num;
	}

	public void setNum(int num) {
		this.num = num;
	}

	public FailNum(int operType, int num) {
		super();
		this.operType = operType;
		this.num = num;
	}

	public FailNum() {
		super();
	}

}
