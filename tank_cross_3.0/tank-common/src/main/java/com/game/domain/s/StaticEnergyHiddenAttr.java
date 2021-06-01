package com.game.domain.s;

import java.util.List;

/**
 * @author TanDonghai @ClassName StaticEnergyHiddenAttr.java @Description 能晶隐藏属性信息
 * @date 创建时间：2016年7月13日 上午10:22:10
 */
public class StaticEnergyHiddenAttr {

  private int attributeID; // 隐藏属性自定义唯一id

  private List<Integer> ruleList; // 隐藏属性激活条件，[镶嵌数量，等级]

  private List<List<Integer>> effectList; // 增加的属性,[属性类别，属性值]

  public int getAttributeID() {
    return attributeID;
  }

  public void setAttributeID(int attributeID) {
    this.attributeID = attributeID;
  }

  public List<Integer> getRuleList() {
    return ruleList;
  }

  public void setRuleList(List<Integer> ruleList) {
    this.ruleList = ruleList;
  }

  public List<List<Integer>> getEffectList() {
    return effectList;
  }

  public void setEffectList(List<List<Integer>> effectList) {
    this.effectList = effectList;
  }

  @Override
  public String toString() {
    return "StaticEnergyHiddenAttr [attributeID="
        + attributeID
        + ", ruleList="
        + ruleList
        + ", effectList="
        + effectList
        + "]";
  }
}
