package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-17 上午10:31:01
 * @Description 军情 民情参数
 */

public class TrendParam {

	private String content;
	private Man man;

	public TrendParam() {
	}

	public TrendParam(String content) {
		this.content = content;
	}

	public TrendParam(String content, long lordId) {
		this.content = content;
		this.man = new Man();
		man.setLordId(lordId);
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public Man getMan() {
		return man;
	}

	public void setMan(Man man) {
		this.man = man;
	}

}
