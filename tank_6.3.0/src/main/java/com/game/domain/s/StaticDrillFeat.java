package com.game.domain.s;

/**
 * @ClassName StaticDrillFeat.java
 * @Description 红蓝大战击毁坦克获得的功勋值配置信息
 * @author TanDonghai
 * @date 创建时间：2016年8月17日 上午9:40:53
 *
 */
public class StaticDrillFeat {
	private int tankId;// 坦克ID

	private float feat;// 击毁一辆坦克可以获得的功勋值

	public int getTankId() {
		return tankId;
	}

	public void setTankId(int tankId) {
		this.tankId = tankId;
	}

	public float getFeat() {
		return feat;
	}

	public void setFeat(float feat) {
		this.feat = feat;
	}

	@Override
	public String toString() {
		return "StaticDrillFeat [tankId=" + tankId + ", feat=" + feat + "]";
	}
}
