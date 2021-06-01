package com.game.domain.s;

public class StaticFortressJob {

  private int id;
  private String name;
  private int effectId;
  private int durationTime;
  private int appointNum;
  private int buffType;
  private String _desc;

  public String get_desc() {
    return _desc;
  }

  public void set_desc(String _desc) {
    this._desc = _desc;
  }

  public int getBuffType() {
    return buffType;
  }

  public void setBuffType(int buffType) {
    this.buffType = buffType;
  }

  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public int getDurationTime() {
    return durationTime;
  }

  public int getEffectId() {
    return effectId;
  }

  public void setEffectId(int effectId) {
    this.effectId = effectId;
  }

  public void setDurationTime(int durationTime) {
    this.durationTime = durationTime;
  }

  public int getAppointNum() {
    return appointNum;
  }

  public void setAppointNum(int appointNum) {
    this.appointNum = appointNum;
  }
}
