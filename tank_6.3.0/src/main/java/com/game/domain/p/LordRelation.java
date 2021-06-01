package com.game.domain.p;

/**
 * @ClassName LordRelation.java
 * @Description 玩家合服前后的lordId对应关系
 * @author TanDonghai
 * @date 创建时间：2016年10月17日 下午4:39:10
 *
 */
public class LordRelation {
	private int keyId;

	private int oldServerId;// 合服前玩家所在服务器id

	private long oldLordId;// 玩家之前的lordId

	private int newServerId;// 合服后玩家所在服的id

	private long newLordId;// 玩家当前的lordId

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getOldServerId() {
		return oldServerId;
	}

	public void setOldServerId(int oldServerId) {
		this.oldServerId = oldServerId;
	}

	public long getOldLordId() {
		return oldLordId;
	}

	public void setOldLordId(long oldLordId) {
		this.oldLordId = oldLordId;
	}

	public int getNewServerId() {
		return newServerId;
	}

	public void setNewServerId(int newServerId) {
		this.newServerId = newServerId;
	}

	public long getNewLordId() {
		return newLordId;
	}

	public void setNewLordId(long newLordId) {
		this.newLordId = newLordId;
	}

	@Override
	public String toString() {
		return "LordRelation [keyId=" + keyId + ", oldServerId=" + oldServerId + ", oldLordId=" + oldLordId
				+ ", newServerId=" + newServerId + ", newLordId=" + newLordId + "]";
	}
}
