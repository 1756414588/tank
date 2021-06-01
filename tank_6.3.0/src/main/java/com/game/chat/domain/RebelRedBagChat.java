package com.game.chat.domain;

import com.game.pb.CommonPb;

/**
 * @author: LiFeng
 * @date:
 * @description: 叛军红包世界消息模板
 */
public class RebelRedBagChat extends Chat {

	private int time;
	private int sysId;
	private int uid;
	private String[] param;

	public int getTime() {
		return time;
	}

	public void setTime(int time) {
		this.time = time;
	}

	public int getSysId() {
		return sysId;
	}

	public void setSysId(int sysId) {
		this.sysId = sysId;
	}

	public int getUid() {
		return uid;
	}

	public void setUid(int uid) {
		this.uid = uid;
	}

	public String[] getParam() {
		return param;
	}

	public void setParam(String[] param) {
		this.param = param;
	}

	@Override
	public com.game.pb.CommonPb.Chat ser(int style) {
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
		builder.setUid(uid);
		builder.setSysId(sysId);
		return builder.build();
	}

}
