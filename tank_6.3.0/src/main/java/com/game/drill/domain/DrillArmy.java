package com.game.drill.domain;

import com.game.domain.p.Form;

/**
 * @ClassName DrillArmy.java
 * @Description 红蓝大战部队
 * @author TanDonghai
 * @date 创建时间：2016年8月16日 上午9:51:02
 *
 */
public class DrillArmy {
	public Form form;// 部队的阵型

	public long fightNum;// 部队阵型的当前战力

	public long totalFight;// 阵型的初始战力

	public DrillArmy() {
	}

	public DrillArmy(Form form) {
		this.form = form;
	}
}
