/**
 * @Title: StaticMine.java @Package com.game.domain.s @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年9月15日 下午12:03:23
 * @version V1.0
 */
package com.game.domain.s;

import java.util.List;

/**
 * @ClassName: StaticMine @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年9月15日 下午12:03:23
 */
public class StaticMine {
  private int pos;
  private int type;
  private int lv;
  private List<List<Integer>> dropOne;

  public int getPos() {
    return pos;
  }

  public void setPos(int pos) {
    this.pos = pos;
  }

  public int getType() {
    return type;
  }

  public void setType(int type) {
    this.type = type;
  }

  public int getLv() {
    return lv;
  }

  public void setLv(int lv) {
    this.lv = lv;
  }

  public List<List<Integer>> getDropOne() {
    return dropOne;
  }

  public void setDropOne(List<List<Integer>> dropOne) {
    this.dropOne = dropOne;
  }
}
