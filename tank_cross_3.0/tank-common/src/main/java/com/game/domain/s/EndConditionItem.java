/**
 * @Title: EndCondition.java @Package com.game.domain.s @Description: TODO
 *
 * @author WanYi
 * @date 2016年4月29日 上午9:47:27
 * @version V1.0
 */
package com.game.domain.s;

/**
 * 后置条件 @ClassName: EndCondition @Description: TODO
 *
 * @author WanYi
 * @date 2016年4月29日 上午9:47:27
 */
public class EndConditionItem {
  private int itemType;
  private int itemId;
  private int quality;
  private int star;
  private int chatId;

  public int getItemType() {
    return itemType;
  }

  public void setItemType(int itemType) {
    this.itemType = itemType;
  }

  public int getItemId() {
    return itemId;
  }

  public void setItemId(int itemId) {
    this.itemId = itemId;
  }

  public int getQuality() {
    return quality;
  }

  public void setQuality(int quality) {
    this.quality = quality;
  }

  public int getStar() {
    return star;
  }

  public void setStar(int star) {
    this.star = star;
  }

  public int getChatId() {
    return chatId;
  }

  public void setChatId(int chatId) {
    this.chatId = chatId;
  }

  @Override
  public String toString() {
    return "EndConditionItem [itemType="
        + itemType
        + ", itemId="
        + itemId
        + ", quality="
        + quality
        + ", star="
        + star
        + ", chatId="
        + chatId
        + "]";
  }
}
