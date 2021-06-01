package com.game.domain.s;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-15 上午11:30:57
 * @declare
 */
public class StaticLiveTask {

  private int taskId;
  private String taskName;
  private int count;
  private int live;

  public int getTaskId() {
    return taskId;
  }

  public void setTaskId(int taskId) {
    this.taskId = taskId;
  }

  public String getTaskName() {
    return taskName;
  }

  public void setTaskName(String taskName) {
    this.taskName = taskName;
  }

  public int getCount() {
    return count;
  }

  public void setCount(int count) {
    this.count = count;
  }

  public int getLive() {
    return live;
  }

  public void setLive(int live) {
    this.live = live;
  }
}
