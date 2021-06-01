package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PlayerService;

public class GetDay7ActTipsHandler extends ClientHandler {

	@Override
	public void action() {
		getService(PlayerService.class).getDay7ActTips(this);
	}

}
