package com.game.domain.p.lordequip;

import com.game.domain.p.AbsBuilding;

/**
 * @author zhangdh @ClassName: LordEquipBuilding @Description: 生产中的军备
 * @date 2017/4/25 14:22
 */
public class LordEquipBuilding extends AbsBuilding {

  private int techId;

  public int getTechId() {
    return techId;
  }

  public void setTechId(int techId) {
    this.techId = techId;
  }

  public LordEquipBuilding(int staticId, int period, int endTime) {
    this.staticId = staticId;
    this.period = period;
    this.endTime = endTime;
    this.count = 1;
  }
}
