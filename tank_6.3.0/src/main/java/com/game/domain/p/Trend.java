package com.game.domain.p;


/**
 * @author ChenKui
 * @version 创建时间：2015-9-16 下午2:38:45
 * @Description 军情 民情
 */

public class Trend {

	private int trendId;
	private String[] param;
	private int trendTime;

	public int getTrendId() {
		return trendId;
	}

	public void setTrendId(int trendId) {
		this.trendId = trendId;
	}

	public String[] getParam() {
		return param;
	}

	public void setParam(String[] param) {
		this.param = param;
	}

	public int getTrendTime() {
		return trendTime;
	}

	public void setTrendTime(int trendTime) {
		this.trendTime = trendTime;
	}

	public Trend(int trendId, int day) {
		this.trendId = trendId;
		this.trendTime = day;
	}

}
