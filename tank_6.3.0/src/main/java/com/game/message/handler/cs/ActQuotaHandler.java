package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ActivityService;

public class ActQuotaHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActivityService.class).actQuotaRq(this);
	}

}
