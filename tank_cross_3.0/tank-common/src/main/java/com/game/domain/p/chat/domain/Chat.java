/**
 * @Title: Chat.java @Package com.game.chat.domain @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年9月21日 下午4:51:14
 * @version V1.0
 */
package com.game.domain.p.chat.domain;

import com.game.pb.CommonPb;

/**
 * @ClassName: Chat @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年9月21日 下午4:51:14
 */
public abstract class Chat {
  public static final int WORLD_CHANNEL = 1;
  public static final int PARTY_CHANNEL = 2;
  public static final int GM_CHANNEL = 3;
  public static final int PRIVATE_CHANNEL = 4;

  protected int channel;

  public abstract CommonPb.Chat ser(int style);

  public int getChannel() {
    return channel;
  }

  public void setChannel(int channel) {
    this.channel = channel;
  }
}
