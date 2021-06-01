package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ActivityService;

public class ActPurpleEqpUpHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActivityService.class).actPurpleEqpUpRq(this);
	}

}
