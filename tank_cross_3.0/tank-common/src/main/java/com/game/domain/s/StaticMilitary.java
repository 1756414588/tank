/**
 * @Title: StaticMilitary.java @Package com.game.domain.s @Description: TODO
 *
 * @author WanYi
 * @date 2016年5月9日 上午10:12:31
 * @version V1.0
 */
package com.game.domain.s;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @ClassName: StaticMilitary @Description: 军工科技
 *
 * @author WanYi
 * @date 2016年5月9日 上午10:12:31
 */
public class StaticMilitary {
  private int tankId;
  private String tankName;
  private int developPoint; // 研发点数
  private int assembleNum; // '装配数'
  private int pukCondition; // '解锁条件,0无;军工科技激活id',
  private List<List<Integer>> gridStatus; // '格子状态\r\n0已解锁\r\n1未解锁\r\n2未开放\r\n3效率\r\n[[0],[0],[1]]',
  private List<List<Integer>> unLockConsume; // '解锁槽位消耗,index, type,id,num\r\n[[]]',
  private List<List<Long>> militaryRefitConsume; // '军工改造消耗\r\n[type,id,num]',
  private int militaryRefitBaseTankId;
  private int productScienceId; // 效率科技id

  // 解锁格子的消耗map
  private Map<Integer, List<List<Integer>>> unLockConsumeMap =
      new HashMap<Integer, List<List<Integer>>>();

  public int getTankId() {
    return tankId;
  }

  public void setTankId(int tankId) {
    this.tankId = tankId;
  }

  public String getTankName() {
    return tankName;
  }

  public void setTankName(String tankName) {
    this.tankName = tankName;
  }

  public int getDevelopPoint() {
    return developPoint;
  }

  public void setDevelopPoint(int developPoint) {
    this.developPoint = developPoint;
  }

  public int getMilitaryRefitBaseTankId() {
    return militaryRefitBaseTankId;
  }

  public void setMilitaryRefitBaseTankId(int militaryRefitBaseTankId) {
    this.militaryRefitBaseTankId = militaryRefitBaseTankId;
  }

  public int getAssembleNum() {
    return assembleNum;
  }

  public void setAssembleNum(int assembleNum) {
    this.assembleNum = assembleNum;
  }

  public int getPukCondition() {
    return pukCondition;
  }

  public void setPukCondition(int pukCondition) {
    this.pukCondition = pukCondition;
  }

  public List<List<Integer>> getGridStatus() {
    return gridStatus;
  }

  public void setGridStatus(List<List<Integer>> gridStatus) {
    this.gridStatus = gridStatus;
  }

  public List<List<Integer>> getUnLockConsume() {
    return unLockConsume;
  }

  public void setUnLockConsume(List<List<Integer>> unLockConsume) {
    this.unLockConsume = unLockConsume;
  }

  public List<List<Long>> getMilitaryRefitConsume() {
    return militaryRefitConsume;
  }

  public void setMilitaryRefitConsume(List<List<Long>> militaryRefitConsume) {
    this.militaryRefitConsume = militaryRefitConsume;
  }

  public int getProductScienceId() {
    return productScienceId;
  }

  public void setProductScienceId(int productScienceId) {
    this.productScienceId = productScienceId;
  }

  public Map<Integer, List<List<Integer>>> getUnLockConsumeMap() {
    return unLockConsumeMap;
  }

  public void setUnLockConsumeMap(Map<Integer, List<List<Integer>>> unLockConsumeMap) {
    this.unLockConsumeMap = unLockConsumeMap;
  }

  @Override
  public String toString() {
    return "StaticMilitary [tankId="
        + tankId
        + ", tankName="
        + tankName
        + ", developPoint="
        + developPoint
        + ", assembleNum="
        + assembleNum
        + ", pukCondition="
        + pukCondition
        + ", gridStatus="
        + gridStatus
        + ", unLockConsume="
        + unLockConsume
        + ", militaryRefitConsume="
        + militaryRefitConsume
        + ", militaryRefitBaseTankId="
        + militaryRefitBaseTankId
        + ", productScienceId="
        + productScienceId
        + "]";
  }
}
