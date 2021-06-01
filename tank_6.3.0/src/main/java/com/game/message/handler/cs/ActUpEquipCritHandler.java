package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ActivityService;

public class ActUpEquipCritHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActivityService.class).actUpEquipCritRq(this);
	}

}
