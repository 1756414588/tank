package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 描述
 * @created 2017/12/20 09:56
 */
public class StaticLaboratoryTech {

  private int kid;
  private int techId;
  private String name;
  private int techLv;
  private int preBuilding;
  private List<List<Integer>> itemConsume;
  private int composeEfficiency;
  private int maxPersonNumber;
  private int personNumberLimit;
  private String picture;

  public int getKid() {
    return kid;
  }

  public void setKid(int kid) {
    this.kid = kid;
  }

  public int getTechId() {
    return techId;
  }

  public void setTechId(int techId) {
    this.techId = techId;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public int getTechLv() {
    return techLv;
  }

  public void setTechLv(int techLv) {
    this.techLv = techLv;
  }

  public int getPreBuilding() {
    return preBuilding;
  }

  public void setPreBuilding(int preBuilding) {
    this.preBuilding = preBuilding;
  }

  public List<List<Integer>> getItemConsume() {
    return itemConsume;
  }

  public void setItemConsume(List<List<Integer>> itemConsume) {
    this.itemConsume = itemConsume;
  }

  public int getComposeEfficiency() {
    return composeEfficiency;
  }

  public void setComposeEfficiency(int composeEfficiency) {
    this.composeEfficiency = composeEfficiency;
  }

  public int getMaxPersonNumber() {
    return maxPersonNumber;
  }

  public void setMaxPersonNumber(int maxPersonNumber) {
    this.maxPersonNumber = maxPersonNumber;
  }

  public int getPersonNumberLimit() {
    return personNumberLimit;
  }

  public void setPersonNumberLimit(int personNumberLimit) {
    this.personNumberLimit = personNumberLimit;
  }

  public String getPicture() {
    return picture;
  }

  public void setPicture(String picture) {
    this.picture = picture;
  }
}
