package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 描述
 * @created 2017/12/20 09:59
 */
public class StaticLaboratoryResearch {

  private int kid;
  private int id;
  private String name;
  private int type;
  private int ifUnlock;
  private List<Integer> preBuilding;
  private List<List<Integer>> itemConsume;
  private int addProduceTime;
  private String description;
  private String picture;

  public int getKid() {
    return kid;
  }

  public void setKid(int kid) {
    this.kid = kid;
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

  public int getType() {
    return type;
  }

  public void setType(int type) {
    this.type = type;
  }

  public int getIfUnlock() {
    return ifUnlock;
  }

  public void setIfUnlock(int ifUnlock) {
    this.ifUnlock = ifUnlock;
  }

  public List<Integer> getPreBuilding() {
    return preBuilding;
  }

  public void setPreBuilding(List<Integer> preBuilding) {
    this.preBuilding = preBuilding;
  }

  public List<List<Integer>> getItemConsume() {
    return itemConsume;
  }

  public void setItemConsume(List<List<Integer>> itemConsume) {
    this.itemConsume = itemConsume;
  }

  public int getAddProduceTime() {
    return addProduceTime;
  }

  public void setAddProduceTime(int addProduceTime) {
    this.addProduceTime = addProduceTime;
  }

  public String getDescription() {
    return description;
  }

  public void setDescription(String description) {
    this.description = description;
  }

  public String getPicture() {
    return picture;
  }

  public void setPicture(String picture) {
    this.picture = picture;
  }
}
