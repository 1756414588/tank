package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.WorldService;

/**
 * 获取新英雄的过期时间
 */
public class GetHeroEndTimeRqHandler extends ClientHandler {

	@Override
	public void action() {
		getService(WorldService.class).getHeroEndTime(this, msg.getExtension(GamePb6.GetHeroEndTimeRq.ext));
	}

}
