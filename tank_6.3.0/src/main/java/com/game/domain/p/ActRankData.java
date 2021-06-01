package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2015-11-18 下午2:36:27
 * @Description:  没用到
 */

public class ActRankData {
	private long id;
	private int sortId;
	private long value;
	private String param;

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public int getSortId() {
		return sortId;
	}

	public void setSortId(int sortId) {
		this.sortId = sortId;
	}

	public long getValue() {
		return value;
	}

	public void setValue(long value) {
		this.value = value;
	}

	public String getParam() {
		return param;
	}

	public void setParam(String param) {
		this.param = param;
	}

	public ActRankData(long id, int sortId, long value) {
		this.id = id;
		this.sortId = sortId;
		this.value = value;
	}

	public ActRankData() {
	}
}
