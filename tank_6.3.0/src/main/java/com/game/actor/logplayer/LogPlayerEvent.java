package com.game.actor.logplayer;

import com.game.domain.p.saveplayerinfo.LogPlayer;
import com.game.server.Actor.IMessage;

import java.util.List;

/**
 * @ClassName:LogPlayerEvent
 * @author zc
 * @Description:
 * @date 2017年9月25日
 */
public class LogPlayerEvent implements IMessage{
	public static final String LOG_PLAYER_ACT = "LOG_PLAYER_ACT";
	private String subject;
	private List<LogPlayer> list;
	
	public LogPlayerEvent(String subject, List<LogPlayer> list) {
		this.subject = subject;
		this.list = list;
	}
	
	@Override
	public String getSubject() {
		return subject;
	}

	@Override
	public Object getData() {
		return list;
	}

}
