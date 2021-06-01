package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.WorldService;

public class GetScoutFreeTimeRqHandler extends ClientHandler {
	@Override
	public void action() {
		getService(WorldService.class).getScoutFreeTime(this);
	}

}
