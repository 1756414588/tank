package com.game.drill.domain;

/**
 * @ClassName DrillREsult.java
 * @Description 红蓝大战战斗结果
 * @author TanDonghai
 * @date 创建时间：2016年8月10日 下午1:56:03
 *
 */
public class DrillResult {

	private int drillRedRest;// 红蓝大战红方剩余部队数量

	private int drillRedTotal;// 红蓝大战红方总共部队数量

	private int drillBlueRest;// 红蓝大战蓝方剩余部队数量

	private int drillBlueTotal;// 红蓝大战蓝方总共部队数量

	private int status;// 0 为出结果或平局，1 红方胜，2 蓝方胜
	
	private boolean isOver;// 本场战斗是否结束

	public DrillResult() {
	}

	public DrillResult(com.game.pb.CommonPb.DrillResult result) {
		this.drillRedRest = result.getRedRest();
		this.drillRedTotal = result.getRedTotal();
		this.drillBlueRest = result.getBlueRest();
		this.drillBlueTotal = result.getBlueTotal();
		if (result.hasRedWin()) {
			this.status = result.getRedWin() ? 1 : 2;
		} else {
			this.status = 0;
		}
		this.isOver = true;
	}

	public int getDrillRedRest() {
		return drillRedRest;
	}

	public void setDrillRedRest(int drillRedRest) {
		this.drillRedRest = drillRedRest;
	}

	public int getDrillRedTotal() {
		return drillRedTotal;
	}

	public void setDrillRedTotal(int drillRedTotal) {
		this.drillRedTotal = drillRedTotal;
	}

	public int getDrillBlueRest() {
		return drillBlueRest;
	}

	public void setDrillBlueRest(int drillBlueRest) {
		this.drillBlueRest = drillBlueRest;
	}

	public int getDrillBlueTotal() {
		return drillBlueTotal;
	}

	public void setDrillBlueTotal(int drillBlueTotal) {
		this.drillBlueTotal = drillBlueTotal;
	}

	public int getStatus() {
		return status;
	}

	public void setStatus(int status) {
		this.status = status;
		this.isOver = true;
	}

	public boolean isOver() {
		return isOver;
	}

	public void setOver(boolean isOver) {
		this.isOver = isOver;
	}

	@Override
	public String toString() {
		return "DrillResult [drillRedRest=" + drillRedRest + ", drillRedTotal=" + drillRedTotal + ", drillBlueRest="
				+ drillBlueRest + ", drillBlueTotal=" + drillBlueTotal + ", status=" + status + ", isOver=" + isOver
				+ "]";
	}

}
