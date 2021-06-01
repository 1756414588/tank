package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.WealDayPartyRq;
import com.game.service.PartyService;

public class WealDayPartyHandler extends ClientHandler {

	@Override
	public void action() {
		WealDayPartyRq req = msg.getExtension(WealDayPartyRq.ext);
		getService(PartyService.class).wealDayPartyRq(req, this);
	}

}
