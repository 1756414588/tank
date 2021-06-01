package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.WorldService;

/**
 * 清除新英雄的cd时间
 */
public class ClearHeroCdRqHandler extends ClientHandler {

	@Override
	public void action() {
		getService(WorldService.class).clearHeroCd(this, msg.getExtension(GamePb6.ClearHeroCdRq.ext));
	}

}
