/**
 * @Title: StaticPart.java @Package com.game.domain.s @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月19日 下午5:26:58
 * @version V1.0
 */
package com.game.domain.s;

import java.util.List;
import java.util.Map;

/**
 * @ClassName: StaticPart @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月19日 下午5:26:58
 */
public class StaticPart {
  private int partId;
  private int type;
  private int quality;
  private int attr1;
  private int attr2;
  private int attr3;
  private int a1;
  private int a2;
  private int a3;
  private int b1;
  private int b2;
  private int b3;
  private int chipCount;

  private int lvMax;
  private List<Integer> smeltExp;
  private Map<Integer, List<Integer>> s_attr;
  private Map<Integer, List<Integer>> s_attrCondition;
  private List<List<Integer>> unlockAttr;
  private List<List<Integer>> unlockAttrCondition;

  public int getPartId() {
    return partId;
  }

  public void setPartId(int partId) {
    this.partId = partId;
  }

  public int getType() {
    return type;
  }

  public void setType(int type) {
    this.type = type;
  }

  public int getQuality() {
    return quality;
  }

  public void setQuality(int quality) {
    this.quality = quality;
  }

  public int getAttr1() {
    return attr1;
  }

  public void setAttr1(int attr1) {
    this.attr1 = attr1;
  }

  public int getAttr2() {
    return attr2;
  }

  public void setAttr2(int attr2) {
    this.attr2 = attr2;
  }

  public int getA1() {
    return a1;
  }

  public void setA1(int a1) {
    this.a1 = a1;
  }

  public int getB1() {
    return b1;
  }

  public void setB1(int b1) {
    this.b1 = b1;
  }

  public int getA2() {
    return a2;
  }

  public void setA2(int a2) {
    this.a2 = a2;
  }

  public int getB2() {
    return b2;
  }

  public void setB2(int b2) {
    this.b2 = b2;
  }

  public int getChipCount() {
    return chipCount;
  }

  public void setChipCount(int chipCount) {
    this.chipCount = chipCount;
  }

  public int getLvMax() {
    return lvMax;
  }

  public void setLvMax(int lvMax) {
    this.lvMax = lvMax;
  }

  public List<Integer> getSmeltExp() {
    return smeltExp;
  }

  public void setSmeltExp(List<Integer> smeltExp) {
    this.smeltExp = smeltExp;
  }

  public Map<Integer, List<Integer>> getS_attr() {
    return s_attr;
  }

  public void setS_attr(Map<Integer, List<Integer>> s_attr) {
    this.s_attr = s_attr;
  }

  public List<List<Integer>> getUnlockAttr() {
    return unlockAttr;
  }

  public void setUnlockAttr(List<List<Integer>> unlockAttr) {
    this.unlockAttr = unlockAttr;
  }

  public Map<Integer, List<Integer>> getS_attrCondition() {
    return s_attrCondition;
  }

  public void setS_attrCondition(Map<Integer, List<Integer>> s_attrCondition) {
    this.s_attrCondition = s_attrCondition;
  }

  public List<List<Integer>> getUnlockAttrCondition() {
    return unlockAttrCondition;
  }

  public void setUnlockAttrCondition(List<List<Integer>> unlockAttrCondition) {
    this.unlockAttrCondition = unlockAttrCondition;
  }

  public int getA3() {
    return a3;
  }

  public void setA3(int a3) {
    this.a3 = a3;
  }

  public int getB3() {
    return b3;
  }

  public void setB3(int b3) {
    this.b3 = b3;
  }

  public int getAttr3() {
    return attr3;
  }

  public void setAttr3(int attr3) {
    this.attr3 = attr3;
  }
}
