/**
 * @Title: DealType.java @Package com.game.message.handler @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月12日 下午1:48:51
 * @version V1.0
 */
package com.game.message.handler;

/**
 * @ClassName: DealType @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月12日 下午1:48:51
 */
public enum DealType {
  PUBLIC(0, "PUBLIC") {},
  MAIN(1, "MAIN") {},
  BUILD_QUE(2, "BUILD_QUE") {},
  TANK_QUE(3, "TANK_QUE") {};

  public int getCode() {
    return code;
  }

  public void setCode(int code) {
    this.code = code;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  private DealType(int code, String name) {
    this.code = code;
    this.name = name;
  }

  private int code;
  private String name;
}
