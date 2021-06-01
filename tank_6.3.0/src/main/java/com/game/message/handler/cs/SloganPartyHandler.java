package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.SloganPartyRq;
import com.game.service.PartyService;

public class SloganPartyHandler extends ClientHandler {

	@Override
	public void action() {
		SloganPartyRq req = msg.getExtension(SloganPartyRq.ext);
		getService(PartyService.class).sloganParty(req, this);
	}

}
