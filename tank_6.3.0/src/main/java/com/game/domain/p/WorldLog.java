/**   
 * @Title: WorldLog.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2016年3月11日 下午6:40:10    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: WorldLog
 * @Description: 世界等级升级日志
 * @author ZhangJun
 * @date 2016年3月11日 下午6:40:10
 * 
 */
public class WorldLog {
	private int keyId;
	private int lvTime;
	private int worldLv;
	private int totalLv;

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getLvTime() {
		return lvTime;
	}

	public void setLvTime(int lvTime) {
		this.lvTime = lvTime;
	}

	public int getWorldLv() {
		return worldLv;
	}

	public void setWorldLv(int worldLv) {
		this.worldLv = worldLv;
	}

	public int getTotalLv() {
		return totalLv;
	}

	public void setTotalLv(int totalLv) {
		this.totalLv = totalLv;
	}

}
