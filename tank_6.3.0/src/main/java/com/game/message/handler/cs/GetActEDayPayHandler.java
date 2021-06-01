package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ActionCenterService;

public class GetActEDayPayHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActionCenterService.class).getActEDayPayRq(this);
	}
}
