package com.game.domain.p;

/**
 * @ClassName: EnergyStoneInlay
 * @Description: 能晶镶嵌信息
 * @author TanDonghai
 * @date 创建时间：2016年7月12日 下午2:19:39
 *
 */
public class EnergyStoneInlay {

	private int hole;// 镶嵌孔id,从1开始

	private int stoneId;// 能晶id

	private int pos;// 出战部位 1.阵型第一格 2.阵型第二格 ...

	public EnergyStoneInlay() {
	}

	public EnergyStoneInlay(int pos, int hole, int stoneId) {
		this.pos = pos;
		this.hole = hole;
		this.stoneId = stoneId;
	}

	public int getHole() {
		return hole;
	}

	public void setHole(int hole) {
		this.hole = hole;
	}

	public int getStoneId() {
		return stoneId;
	}

	public void setStoneId(int stoneId) {
		this.stoneId = stoneId;
	}

	public int getPos() {
		return pos;
	}

	public void setPos(int pos) {
		this.pos = pos;
	}

	@Override
	public String toString() {
		return "EnergyStoneInlay [hole=" + hole + ", stoneId=" + stoneId + ", pos=" + pos + "]";
	}
}
