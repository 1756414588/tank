/**   
 * @Title: SystemChat.java    
 * @Package com.game.chat.domain    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月21日 下午4:48:54    
 * @version V1.0   
 */
package com.game.chat.domain;

import com.game.pb.CommonPb;

/**
 * @ClassName: SystemChat
 * @Description: 系统公告
 * @author ZhangJun
 * @date 2015年9月21日 下午4:48:54
 * 
 */
public class SystemChat extends Chat {
	private int time;
	private int sysId;
	private String[] param;

	public int getSysId() {
		return sysId;
	}

	public void setSysId(int sysId) {
		this.sysId = sysId;
	}

	public String[] getParam() {
		return param;
	}

	public void setParam(String[] param) {
		this.param = param;
	}

	public int getTime() {
		return time;
	}

	public void setTime(int time) {
		this.time = time;
	}

	/**
	 * Overriding: ser
	 * 
	 * @return
	 * @see com.game.chat.domain.Chat#ser()
	 */
	@Override
	public com.game.pb.CommonPb.Chat ser(int style) {
		//Auto-generated method stub
		CommonPb.Chat.Builder builder = CommonPb.Chat.newBuilder();
		builder.setTime(time);
		builder.setChannel(channel);

		if (style != 0) {
			builder.setStyle(style);
		}

		if (param != null) {
			for (int i = 0; i < param.length; i++) {
				if (param[i] != null) {
					builder.addParam(param[i]);
				}
			}
		}
		
		builder.setSysId(sysId);
		return builder.build();
	}

}
