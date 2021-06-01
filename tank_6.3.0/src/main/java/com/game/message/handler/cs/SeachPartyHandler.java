package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.SeachPartyRq;
import com.game.service.PartyService;

public class SeachPartyHandler extends ClientHandler {

	@Override
	public void action() {
		SeachPartyRq req = msg.getExtension(SeachPartyRq.ext);
		getService(PartyService.class).seachParty(req, this);
	}

}
