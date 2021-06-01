/**
 * @Title: StaticMilitaryMaterial.java @Package com.game.domain.s @Description: TODO
 *
 * @author WanYi
 * @date 2016年5月11日 下午4:13:31
 * @version V1.0
 */
package com.game.domain.s;

/**
 * @ClassName: StaticMilitaryMaterial @Description: 军工材料
 *
 * @author WanYi
 * @date 2016年5月11日 下午4:13:31
 */
public class StaticMilitaryMaterial {

  private int id;
  private String name;
  private int type; // 1矿2药剂

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
}
