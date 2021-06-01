/**
 * @Title: StaticMilitaryDevelopTree.java @Package com.game.domain.s @Description: TODO
 *
 * @author WanYi
 * @date 2016年5月9日 上午10:23:14
 * @version V1.0
 */
package com.game.domain.s;

import java.util.List;

/**
 * @ClassName: StaticMilitaryDevelopTree @Description: TODO
 *
 * @author WanYi
 * @date 2016年5月9日 上午10:23:14
 */
public class StaticMilitaryDevelopTree {
  private int id; // int(11) NOT NULL COMMENT '科技名',;
  private int level; // ` int(255) NOT NULL DEFAULT '1' COMMENT '等级',
  private int attrId;
  private int tankId; // int(11) DEFAULT NULL COMMENT 'tankId',
  private List<List<Integer>> materials;
  private List<List<Integer>> effect;
  private List<List<Integer>> scope;
  private List<List<Integer>> require;

  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public int getLevel() {
    return level;
  }

  public void setLevel(int level) {
    this.level = level;
  }

  public int getTankId() {
    return tankId;
  }

  public void setTankId(int tankId) {
    this.tankId = tankId;
  }

  public int getAttrId() {
    return attrId;
  }

  public void setAttrId(int attrId) {
    this.attrId = attrId;
  }

  public List<List<Integer>> getMaterials() {
    return materials;
  }

  public void setMaterials(List<List<Integer>> materials) {
    this.materials = materials;
  }

  public List<List<Integer>> getEffect() {
    return effect;
  }

  public void setEffect(List<List<Integer>> effect) {
    this.effect = effect;
  }

  public List<List<Integer>> getScope() {
    return scope;
  }

  public void setScope(List<List<Integer>> scope) {
    this.scope = scope;
  }

  public List<List<Integer>> getRequire() {
    return require;
  }

  public void setRequire(List<List<Integer>> require) {
    this.require = require;
  }

  @Override
  public String toString() {
    return "StaticMilitaryDevelopTree [id="
        + id
        + ", level="
        + level
        + ", attrId="
        + attrId
        + ", tankId="
        + tankId
        + ", materials="
        + materials
        + ", effect="
        + effect
        + ", scope="
        + scope
        + ", require="
        + require
        + "]";
  }
}
