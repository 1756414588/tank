package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/05/26 13:56
 */
public class StaticEquipUpStar {

  private int keyId;
  private int beforeStarLv;
  private int starUpProperty;
  private int needEquip;
  private List<List<Integer>> need;

  public int getKeyId() {
    return keyId;
  }

  public void setKeyId(int keyId) {
    this.keyId = keyId;
  }

  public int getBeforeStarLv() {
    return beforeStarLv;
  }

  public void setBeforeStarLv(int beforeStarLv) {
    this.beforeStarLv = beforeStarLv;
  }

  public int getStarUpProperty() {
    return starUpProperty;
  }

  public void setStarUpProperty(int starUpProperty) {
    this.starUpProperty = starUpProperty;
  }

  public List<List<Integer>> getNeed() {
    return need;
  }

  public void setNeed(List<List<Integer>> need) {
    this.need = need;
  }

  public int getNeedEquip() {
    return needEquip;
  }

  public void setNeedEquip(int needEquip) {
    this.needEquip = needEquip;
  }
}
