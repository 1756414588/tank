package com.game.domain.p;

/**
 * @author zhangdh @ClassName: IBuilding @Description: 表示一个建造(生产)的物品或者等待被建造(生产)的物品
 * @date 2017/4/24 11:59
 */
public interface IBuilding {

  int getStaticId();

  /**
   * 生产周期
   *
   * @return
   */
  long getPeriod();

  /**
   * 完成时间
   *
   * @return
   */
  long getEndTime();

  /**
   * 生产数量
   *
   * @return
   */
  int getBuildCount();

  /**
   * 重新设置建造结束时间
   *
   * @param endTime
   */
  void setEndTime(long endTime);
}
