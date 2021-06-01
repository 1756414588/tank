package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.WorldService;

/**
 * 获取新英雄的cd时间
 */
public class GetHeroCdRqHandler extends ClientHandler {

	@Override
	public void action() {
		getService(WorldService.class).getHeroCd(this, msg.getExtension(GamePb6.GetHeroCdRq.ext));
	}

}
