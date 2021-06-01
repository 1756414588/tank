package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.GetPartyRq;
import com.game.service.PartyService;

public class GetPartyHandler extends ClientHandler {

	@Override
	public void action() {
		GetPartyRq req = msg.getExtension(GetPartyRq.ext);
		getService(PartyService.class).getParty(req, this);
	}

}
