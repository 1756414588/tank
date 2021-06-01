package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PartyService;

public class GetPartyHallHandler extends ClientHandler {

	@Override
	public void action() {
		getService(PartyService.class).getPartyHallRq(this);
	}

}
