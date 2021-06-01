package com.game.domain.s;

import java.util.List;

public class StaticEquipBonusAttribute {
  private int quality;
  private int number;
  private List<List<Integer>> attribute;

  public int getQuality() {
    return quality;
  }

  public void setQuality(int quality) {
    this.quality = quality;
  }

  public int getNumber() {
    return number;
  }

  public void setNumber(int number) {
    this.number = number;
  }

  public List<List<Integer>> getAttribute() {
    return attribute;
  }

  public void setAttribute(List<List<Integer>> attribute) {
    this.attribute = attribute;
  }
}
