/**
 * @Title: StaticActionMsg.java @Package com.game.domain.s @Description: TODO
 *
 * @author WanYi
 * @date 2016年4月28日 下午5:34:42
 * @version V1.0
 */
package com.game.domain.s;

/**
 * 行为产生的消息推送表 @ClassName: StaticActionMsg @Description: TODO
 *
 * @author WanYi
 * @date 2016年4月28日 下午5:34:42
 */
public class StaticActionMsg {
  private int id;
  private int type;
  private String preCondition;
  private String endCondition;
  private int chatId;
  private String _desc;

  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public int getType() {
    return type;
  }

  public void setType(int type) {
    this.type = type;
  }

  public String getPreCondition() {
    return preCondition;
  }

  public void setPreCondition(String preCondition) {
    this.preCondition = preCondition;
  }

  public String getEndCondition() {
    return endCondition;
  }

  public void setEndCondition(String endCondition) {
    this.endCondition = endCondition;
  }

  public int getChatId() {
    return chatId;
  }

  public void setChatId(int chatId) {
    this.chatId = chatId;
  }

  public String get_desc() {
    return _desc;
  }

  public void set_desc(String _desc) {
    this._desc = _desc;
  }

  @Override
  public String toString() {
    return "StaticActionMsg [id="
        + id
        + ", type="
        + type
        + ", preCondition="
        + preCondition
        + ", endCondition="
        + endCondition
        + ", chatId="
        + chatId
        + ", _desc="
        + _desc
        + "]";
  }
}
