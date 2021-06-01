package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2016-4-23 下午3:02:39
* @Description: 作弊举报
 */

public class TipGuy {

	private long lordId;
	private int vip;
	private int level;
	private int count;
	private byte[] tips;
	private String content;

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public int getVip() {
		return vip;
	}

	public void setVip(int vip) {
		this.vip = vip;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public byte[] getTips() {
		return tips;
	}

	public void setTips(byte[] tips) {
		this.tips = tips;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

}
