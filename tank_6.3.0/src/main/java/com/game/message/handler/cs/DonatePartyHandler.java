package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.DonatePartyRq;
import com.game.service.PartyService;

public class DonatePartyHandler extends ClientHandler {

	@Override
	public void action() {
		DonatePartyRq req = msg.getExtension(DonatePartyRq.ext);
		getService(PartyService.class).donatePartyRq(req, this);
	}

}
