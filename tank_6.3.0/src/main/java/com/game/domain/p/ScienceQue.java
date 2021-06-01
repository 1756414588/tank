package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2015-8-28 下午3:25:02
 * @Description: 科技升级
 */

public class ScienceQue {

	private int keyId;
	private int scienceId;
	private int period;
	private int state; // 0等待队列 1正在升级
	private int endTime;
	private int stoneCost;
	private int ironCost;
	private int copperCost;
	private int oilCost;
	private int silionCost;

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getScienceId() {
		return scienceId;
	}

	public void setScienceId(int scienceId) {
		this.scienceId = scienceId;
	}

	public int getPeriod() {
		return period;
	}

	public void setPeriod(int period) {
		this.period = period;
	}

	public int getState() {
		return state;
	}

	public void setState(int state) {
		this.state = state;
	}

	public int getEndTime() {
		return endTime;
	}

	public void setEndTime(int endTime) {
		this.endTime = endTime;
	}

	public ScienceQue() {
	}

	public int getStoneCost() {
		return stoneCost;
	}

	public void setStoneCost(int stoneCost) {
		this.stoneCost = stoneCost;
	}

	public int getIronCost() {
		return ironCost;
	}

	public void setIronCost(int ironCost) {
		this.ironCost = ironCost;
	}

	public int getCopperCost() {
		return copperCost;
	}

	public void setCopperCost(int copperCost) {
		this.copperCost = copperCost;
	}

	public int getOilCost() {
		return oilCost;
	}

	public void setOilCost(int oilCost) {
		this.oilCost = oilCost;
	}

	public int getSilionCost() {
		return silionCost;
	}

	public void setSilionCost(int silionCost) {
		this.silionCost = silionCost;
	}

	public void saveCost(int stoneCost, int ironCost, int copperCost, int oilCost, int silionCost) {
		if (ironCost < 0 || oilCost < 0 || copperCost < 0 || silionCost < 0 || stoneCost < 0) {
			return;
		}
		this.stoneCost = stoneCost;
		this.ironCost = ironCost;
		this.copperCost = copperCost;
		this.oilCost = oilCost;
		this.silionCost = silionCost;
	}

	public ScienceQue(int keyId, int scienceId, int period, int state, int endTime) {
		this.keyId = keyId;
		this.scienceId = scienceId;
		this.period = period;
		this.state = state;
		this.endTime = endTime;
	}

	@Override
	public String toString() {
		return "ScienceQue [keyId=" + keyId + ", scienceId=" + scienceId + ", period=" + period + ", state=" + state + ", endTime="
				+ endTime + ", stoneCost=" + stoneCost + ", ironCost=" + ironCost + ", copperCost=" + copperCost + ", oilCost=" + oilCost
				+ ", silionCost=" + silionCost + "]";
	}

}
