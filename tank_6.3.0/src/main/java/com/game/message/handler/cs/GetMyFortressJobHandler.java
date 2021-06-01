package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.FortressWarService;

public class GetMyFortressJobHandler extends ClientHandler {

	@Override
	public void action() {
		getService(FortressWarService.class).getMyFortressJob(this);
	}

}
