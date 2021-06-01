/**
 * @Title: StaticBuilding.java @Package com.game.domain.s @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年7月20日 下午3:40:51
 * @version V1.0
 */
package com.game.domain.s;

/**
 * @ClassName: StaticBuilding @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年7月20日 下午3:40:51
 */
public class StaticBuilding {
  private int buildingId;
  private String name;
  private int type;
  private int canUp;
  private int canDestory;
  private int canResource;
  private int initLv;
  private int pros;

  public int getBuildingId() {
    return buildingId;
  }

  public void setBuildingId(int buildingId) {
    this.buildingId = buildingId;
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

  public int getCanUp() {
    return canUp;
  }

  public void setCanUp(int canUp) {
    this.canUp = canUp;
  }

  public int getCanDestory() {
    return canDestory;
  }

  public void setCanDestory(int canDestory) {
    this.canDestory = canDestory;
  }

  public int getInitLv() {
    return initLv;
  }

  public void setInitLv(int initLv) {
    this.initLv = initLv;
  }

  public int getPros() {
    return pros;
  }

  public void setPros(int pros) {
    this.pros = pros;
  }

  public int getCanResource() {
    return canResource;
  }

  public void setCanResource(int canResource) {
    this.canResource = canResource;
  }
}
