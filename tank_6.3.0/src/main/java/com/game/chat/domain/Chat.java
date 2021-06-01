/**   
 * @Title: Chat.java    
 * @Package com.game.chat.domain    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月21日 下午4:51:14    
 * @version V1.0   
 */
package com.game.chat.domain;

import com.game.pb.CommonPb;

/**
 * @ClassName: Chat
 * @Description: 公告基类
 * @author ZhangJun
 * @date 2015年9月21日 下午4:51:14
 * 
 */
public abstract class Chat {
	static final public int WORLD_CHANNEL = 1;
	static final public int PARTY_CHANNEL = 2;
	static final public int GM_CHANNEL = 3;
	static final public int PRIVATE_CHANNEL = 4;
	static final public int CROSSTEAM_CHANNEL = 6;

	protected int channel;

	abstract public CommonPb.Chat ser(int style);

	public int getChannel() {
		return channel;
	}

	public void setChannel(int channel) {
		this.channel = channel;
	}
}
