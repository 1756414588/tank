package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ActivityService;

public class ActCollectHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActivityService.class).actCollectRq(this);
	}

}
