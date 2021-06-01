package com.game.drill.domain;

/**
 * @ClassName DrillImproveInfo.java
 * @Description 红蓝大战增益等级
 * @author TanDonghai
 * @date 创建时间：2016年8月11日 下午5:01:56
 *
 */
public class DrillImproveInfo {
	private int buffId; // buffId
	private int buffLv; // buff当前等级
	private int exper; // 本级buff当前的经验值

	public DrillImproveInfo() {
	}

	public DrillImproveInfo(com.game.pb.CommonPb.DrillImproveInfo info) {
		this.buffId = info.getBuffId();
		this.buffLv = info.getBuffLv();
		this.exper = info.getExper();
	}

	public int getBuffId() {
		return buffId;
	}

	public void setBuffId(int buffId) {
		this.buffId = buffId;
	}

	public int getBuffLv() {
		return buffLv;
	}

	public void setBuffLv(int buffLv) {
		this.buffLv = buffLv;
	}

	public int getExper() {
		return exper;
	}

	public void setExper(int exper) {
		this.exper = exper;
	}

	@Override
	public String toString() {
		return "DrillImproveInfo [buffId=" + buffId + ", buffLv=" + buffLv + ", exper=" + exper + "]";
	}

}
