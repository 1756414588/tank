package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.FortressWarService;

public class GetFortressAttrHandler extends ClientHandler {

	@Override
	public void action() {
		getService(FortressWarService.class).getFortressAttr(this);
	}

}
