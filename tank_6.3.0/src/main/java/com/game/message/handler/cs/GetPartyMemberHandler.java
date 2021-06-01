package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PartyService;

public class GetPartyMemberHandler extends ClientHandler {

	@Override
	public void action() {
		getService(PartyService.class).getPartyMember(this);
	}

}
