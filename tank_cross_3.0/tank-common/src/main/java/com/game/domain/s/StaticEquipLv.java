/**
 * @Title: StaticEquipLv.java @Package com.game.domain.s @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月18日 上午11:17:40
 * @version V1.0
 */
package com.game.domain.s;

/**
 * @ClassName: StaticEquipLv @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月18日 上午11:17:40
 */
public class StaticEquipLv {
  private int quality;
  private int level;
  private int needExp;
  private int giveExp;

  public int getQuality() {
    return quality;
  }

  public void setQuality(int quality) {
    this.quality = quality;
  }

  public int getLevel() {
    return level;
  }

  public void setLevel(int level) {
    this.level = level;
  }

  public int getNeedExp() {
    return needExp;
  }

  public void setNeedExp(int needExp) {
    this.needExp = needExp;
  }

  public int getGiveExp() {
    return giveExp;
  }

  public void setGiveExp(int giveExp) {
    this.giveExp = giveExp;
  }
}
