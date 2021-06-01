package com.game.chat.domain;

import com.game.pb.CommonPb;

/**
 * @author: LiFeng
 * @date: 4.25
 * @description: 世界频道队伍邀请
 */
public class TeamInviteChat extends Chat {

	private int time;
	private int sysId;
	private int teamId;
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

	public int getTeamId() {
		return teamId;
	}

	public void setTeamId(int teamId) {
		this.teamId = teamId;
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
		builder.setTeamId(teamId);
		builder.setSysId(sysId);
		return builder.build();
	}

}
