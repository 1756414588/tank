package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ActionCenterService;

public class GetActConsumeDialRankHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActionCenterService.class).getActConsumeDialRankRq(this);
	}

}
