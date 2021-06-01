package com.game.domain.s;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-16 上午10:01:02
 * @declare
 */
public class StaticTask {

  private int taskId;
  private int type;
  private int typeChild;
  private int triggerId;
  private int taskStar;
  private int probability;
  private int cond;
  private int schedule;
  private int finishCount;
  private int exp;
  private int live;
  private List<List<Integer>> awardList;
  private List<Integer> param;

  public int getTaskId() {
    return taskId;
  }

  public void setTaskId(int taskId) {
    this.taskId = taskId;
  }

  public int getType() {
    return type;
  }

  public void setType(int type) {
    this.type = type;
  }

  public int getTypeChild() {
    return typeChild;
  }

  public void setTypeChild(int typeChild) {
    this.typeChild = typeChild;
  }

  public int getTriggerId() {
    return triggerId;
  }

  public void setTriggerId(int triggerId) {
    this.triggerId = triggerId;
  }

  public int getTaskStar() {
    return taskStar;
  }

  public void setTaskStar(int taskStar) {
    this.taskStar = taskStar;
  }

  public int getProbability() {
    return probability;
  }

  public void setProbability(int probability) {
    this.probability = probability;
  }

  public int getCond() {
    return cond;
  }

  public void setCond(int cond) {
    this.cond = cond;
  }

  public int getSchedule() {
    return schedule;
  }

  public void setSchedule(int schedule) {
    this.schedule = schedule;
  }

  public int getFinishCount() {
    return finishCount;
  }

  public void setFinishCount(int finishCount) {
    this.finishCount = finishCount;
  }

  public int getExp() {
    return exp;
  }

  public void setExp(int exp) {
    this.exp = exp;
  }

  public int getLive() {
    return live;
  }

  public void setLive(int live) {
    this.live = live;
  }

  public List<List<Integer>> getAwardList() {
    return awardList;
  }

  public void setAwardList(List<List<Integer>> awardList) {
    this.awardList = awardList;
  }

  public List<Integer> getParam() {
    return param;
  }

  public void setParam(List<Integer> param) {
    this.param = param;
  }
}
