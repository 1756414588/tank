package com.game.domain.p;

/**
 * @author zhangdh @ClassName: AbsBuilding @Description: :
 * @date 2017/4/25 14:29
 */
public abstract class AbsBuilding implements IBuilding {
  protected int staticId; // 静态数据ID
  protected int count; // 生产数量
  protected long period; // 生产周期
  protected long endTime; // 生产结束时间

  @Override
  public int getStaticId() {
    return staticId;
  }

  @Override
  public long getPeriod() {
    return period;
  }

  @Override
  public long getEndTime() {
    return endTime;
  }

  @Override
  public int getBuildCount() {
    return count;
  }

  @Override
  public void setEndTime(long endTime) {
    this.endTime = endTime;
  }

  public int getCount() {
    return count;
  }
}
