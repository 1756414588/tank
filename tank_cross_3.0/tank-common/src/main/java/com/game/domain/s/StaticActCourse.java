package com.game.domain.s;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2015-12-15 下午2:27:06
 * @declare
 */
public class StaticActCourse {

  private int courseId;
  private int activityId;
  private int sctionId;
  private int deno;
  private List<List<Integer>> dropList;

  public int getCourseId() {
    return courseId;
  }

  public void setCourseId(int courseId) {
    this.courseId = courseId;
  }

  public int getActivityId() {
    return activityId;
  }

  public void setActivityId(int activityId) {
    this.activityId = activityId;
  }

  public int getSctionId() {
    return sctionId;
  }

  public void setSctionId(int sctionId) {
    this.sctionId = sctionId;
  }

  public int getDeno() {
    return deno;
  }

  public void setDeno(int deno) {
    this.deno = deno;
  }

  public List<List<Integer>> getDropList() {
    return dropList;
  }

  public void setDropList(List<List<Integer>> dropList) {
    this.dropList = dropList;
  }
}
