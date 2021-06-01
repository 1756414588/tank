package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-2 下午2:50:52
 * @Description: 好友
 */

public class Friend {

	private long lordId;
	private int bless;
	private int blessTime;

	/**
	 * 友好度
	 */
	private int friendliness;

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public int getBless() {
		return bless;
	}

	public void setBless(int bless) {
		this.bless = bless;
	}

	public int getBlessTime() {
		return blessTime;
	}

	public void setBlessTime(int blessTime) {
		this.blessTime = blessTime;
	}

	public int getFriendliness() {
		return friendliness;
	}

	public void setFriendliness(int friendliness) {
		this.friendliness = friendliness;
	}

	public Friend(long lordId, int bless, int blessTime) {
		this.lordId = lordId;
		this.bless = bless;
		this.blessTime = blessTime;
	}

}
