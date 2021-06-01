package com.game.message.handler.cs.rebel;

import com.game.message.handler.ClientHandler;
import com.game.service.RebelService;

public class GetRebelDataHandler extends ClientHandler {

	@Override
	public void action() {
		getService(RebelService.class).getRebelData(this);
	}
}
