package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PartyService;

public class QuitPartyHandler extends ClientHandler {

	@Override
	public void action() {
		getService(PartyService.class).quitPartyRq(this);
	}

}
