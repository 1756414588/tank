/**   
 * @Title: BuildQue.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月21日 下午3:46:32    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: BuildQue
 * @Description: 建筑建造或升级
 * @author ZhangJun
 * @date 2015年7月21日 下午3:46:32
 * 
 */
public class BuildQue {
	private int keyId;
	private int buildingId;
	private int pos;
	private int period; // 建造或者升级所需时间
	private int endTime; // 建造或者升级结束时间点
	private int goldCost;
	private long ironCost;
	private long oilCost;
	private long copperCost;
	private long siliconCost;

	public void saveCost(long ironCost, long oilCost, long copperCost, long siliconCost) {
		if (ironCost < 0 || oilCost < 0 || copperCost < 0 || siliconCost < 0) {
			return;
		}
		this.ironCost = ironCost;
		this.oilCost = oilCost;
		this.copperCost = copperCost;
		this.siliconCost = siliconCost;
	}

	public long getIronCost() {
		return ironCost;
	}

	public void setIronCost(long ironCost) {
		this.ironCost = ironCost;
	}

	public long getOilCost() {
		return oilCost;
	}

	public void setOilCost(long oilCost) {
		this.oilCost = oilCost;
	}

	public long getCopperCost() {
		return copperCost;
	}

	public void setCopperCost(long copperCost) {
		this.copperCost = copperCost;
	}

	public long getSiliconCost() {
		return siliconCost;
	}

	public void setSiliconCost(long siliconCost) {
		this.siliconCost = siliconCost;
	}

	public int getGoldCost() {
		return goldCost;
	}

	public void setGoldCost(int goldCost) {
		this.goldCost = goldCost;
	}

	public int getBuildingId() {
		return buildingId;
	}

	public void setBuildingId(int buildingId) {
		this.buildingId = buildingId;
	}

	public int getPos() {
		return pos;
	}

	public void setPos(int pos) {
		this.pos = pos;
	}

	public int getEndTime() {
		return endTime;
	}

	public void setEndTime(int endTime) {
		this.endTime = endTime;
	}

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getPeriod() {
		return period;
	}

	public void setPeriod(int period) {
		this.period = period;
	}

	/**
	 * @param keyId
	 * @param buildingId
	 * @param pos
	 * @param period
	 * @param endTime
	 */
	public BuildQue(int keyId, int buildingId, int pos, int period, int endTime) {
		super();
		this.keyId = keyId;
		this.buildingId = buildingId;
		this.pos = pos;
		this.period = period;
		this.endTime = endTime;
	}

	@Override
	public String toString() {
		return "BuildQue [keyId=" + keyId + ", buildingId=" + buildingId + ", pos=" + pos + ", period=" + period + ", endTime=" + endTime
				+ ", goldCost=" + goldCost + ", ironCost=" + ironCost + ", oilCost=" + oilCost + ", copperCost=" + copperCost
				+ ", siliconCost=" + siliconCost + "]";
	}
	
	

}
