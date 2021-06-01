package com.game.domain.p.corss;

/**
 * 
* @ClassName: DbCrossFameInfo 
* @Description: 跨服战名人堂持久化domain
* @author
 */
public class DbCrossFameInfo {
	private int keyId;
	private String beginTime;
	private String endTime;
	private byte[] crossFames;

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public String getBeginTime() {
		return beginTime;
	}

	public void setBeginTime(String beginTime) {
		this.beginTime = beginTime;
	}

	public String getEndTime() {
		return endTime;
	}

	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}

	public byte[] getCrossFames() {
		return crossFames;
	}

	public void setCrossFames(byte[] crossFames) {
		this.crossFames = crossFames;
	}
}
