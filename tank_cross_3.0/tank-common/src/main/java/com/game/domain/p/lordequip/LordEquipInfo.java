package com.game.domain.p.lordequip;

import com.game.domain.p.Prop;

import java.util.*;

/**
 * @author zhangdh @ClassName: LordEquipInfo @Description: 玩家的军备信息
 * @date 2017/5/13 10:30
 */
public class LordEquipInfo {
  // 指挥官身上的装备, KEY:穿戴位置, VALUE:军备
  private Map<Integer, LordEquip> putonLordEquips = new HashMap<>();

  // 指挥官仓库中的军备信息, KEY:uid, VALUE:军备
  private Map<Integer, LordEquip> storeLordEquips = new HashMap<>();

  // 军备材料图纸
  private Map<Integer, Prop> leqMat = new HashMap<>();

  // 已经解锁的最高级的铁匠
  private int unlock_tech_max;

  // 是否有一次免费雇佣机会
  private boolean free;

  // 雇佣的铁匠ID
  private int employTechId;

  // 雇佣的时间
  private int employEndTime;

  // 生产中的军备
  private List<LordEquipBuilding> leq_que = new LinkedList<>();

  // 生产中的军备材料
  private List<LordEquipMatBuilding> leq_mat_que = new ArrayList<>();

  // 已经购买的军备材料生产坑位
  private int buyMatCount;

  public Map<Integer, LordEquip> getPutonLordEquips() {
    return putonLordEquips;
  }

  public Map<Integer, LordEquip> getStoreLordEquips() {
    return storeLordEquips;
  }

  public Map<Integer, Prop> getLeqMat() {
    return leqMat;
  }

  public void setLeqMat(Map<Integer, Prop> leqMat) {
    this.leqMat = leqMat;
  }

  public int getUnlock_tech_max() {
    return unlock_tech_max;
  }

  public void setUnlock_tech_max(int unlock_tech_max) {
    this.unlock_tech_max = unlock_tech_max;
  }

  public boolean isFree() {
    return free;
  }

  public void setFree(boolean free) {
    this.free = free;
  }

  public int getEmployTechId() {
    return employTechId;
  }

  public void setEmployTechId(int employTechId) {
    this.employTechId = employTechId;
  }

  public int getEmployEndTime() {
    return employEndTime;
  }

  public void setEmployEndTime(int employEndTime) {
    this.employEndTime = employEndTime;
  }

  public List<LordEquipBuilding> getLeq_que() {
    return leq_que;
  }

  public void setLeq_que(List<LordEquipBuilding> leq_que) {
    this.leq_que = leq_que;
  }

  public List<LordEquipMatBuilding> getLeq_mat_que() {
    return leq_mat_que;
  }

  public int getBuyMatCount() {
    return buyMatCount;
  }

  public void setBuyMatCount(int buyMatCount) {
    this.buyMatCount = buyMatCount;
  }
}
