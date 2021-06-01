/**
 * @Title: StaticBuff.java @Package com.game.domain.s @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年9月2日 上午11:18:09
 * @version V1.0
 */
package com.game.domain.s;

/**
 * @ClassName: StaticBuff @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年9月2日 上午11:18:09
 */
public class StaticBuff {
  private int buffId;
  private int groupId;
  private int type;
  private int target;
  private int effectType;
  private int effectValue;

  public int getBuffId() {
    return buffId;
  }

  public void setBuffId(int buffId) {
    this.buffId = buffId;
  }

  public int getGroupId() {
    return groupId;
  }

  public void setGroupId(int groupId) {
    this.groupId = groupId;
  }

  public int getType() {
    return type;
  }

  public void setType(int type) {
    this.type = type;
  }

  public int getTarget() {
    return target;
  }

  public void setTarget(int target) {
    this.target = target;
  }

  public int getEffectType() {
    return effectType;
  }

  public void setEffectType(int effectType) {
    this.effectType = effectType;
  }

  public int getEffectValue() {
    return effectValue;
  }

  public void setEffectValue(int effectValue) {
    this.effectValue = effectValue;
  }
}
