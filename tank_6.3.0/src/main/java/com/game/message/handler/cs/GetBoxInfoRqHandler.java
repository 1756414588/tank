package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ActivityNewService;
import com.game.service.SignService;

public class GetBoxInfoRqHandler extends ClientHandler {
	@Override
	public void action() {
		getService(ActivityNewService.class).getBoxInfo(this);
	}

}
