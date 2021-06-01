package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PartyService;

public class GetPartyCombatHander extends ClientHandler {

	@Override
	public void action() {
		// GetPartyCombatRq req = msg.getExtension(GetPartyCombatRq.ext);
		// getService(PartyService.class).getPartyCombat(req, this);

		getService(PartyService.class).getPartyCombat(this);
	}

}
