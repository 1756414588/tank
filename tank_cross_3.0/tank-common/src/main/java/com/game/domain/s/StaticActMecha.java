package com.game.domain.s;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2015-10-29 下午5:26:47
 * @declare
 */
public class StaticActMecha {

  private int mechaId;
  private int activityId;
  private String name;
  private int count;
  private int cost;
  private int tank;
  private List<List<Integer>> tank1PartList;
  private List<List<Integer>> tank2PartList;
  private List<List<Integer>> critList;
  private String desc;

  public int getMechaId() {
    return mechaId;
  }

  public void setMechaId(int mechaId) {
    this.mechaId = mechaId;
  }

  public int getActivityId() {
    return activityId;
  }

  public void setActivityId(int activityId) {
    this.activityId = activityId;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public int getCount() {
    return count;
  }

  public void setCount(int count) {
    this.count = count;
  }

  public int getCost() {
    return cost;
  }

  public void setCost(int cost) {
    this.cost = cost;
  }

  public int getTank() {
    return tank;
  }

  public void setTank(int tank) {
    this.tank = tank;
  }

  public List<List<Integer>> getTank1PartList() {
    return tank1PartList;
  }

  public void setTank1PartList(List<List<Integer>> tank1PartList) {
    this.tank1PartList = tank1PartList;
  }

  public List<List<Integer>> getTank2PartList() {
    return tank2PartList;
  }

  public void setTank2PartList(List<List<Integer>> tank2PartList) {
    this.tank2PartList = tank2PartList;
  }

  public List<List<Integer>> getCritList() {
    return critList;
  }

  public void setCritList(List<List<Integer>> critList) {
    this.critList = critList;
  }

  public String getDesc() {
    return desc;
  }

  public void setDesc(String desc) {
    this.desc = desc;
  }
}
