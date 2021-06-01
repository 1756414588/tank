package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PlayerService;

public class Day7ActLvUpHandler extends ClientHandler {

	@Override
	public void action() {
		getService(PlayerService.class).day7ActLvUp(this);
	}

}
