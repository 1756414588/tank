package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.GetPartyTrendRq;
import com.game.service.PartyService;

public class GetPartyTrendHandler extends ClientHandler {

	@Override
	public void action() {
		GetPartyTrendRq req = msg.getExtension(GetPartyTrendRq.ext);
		getService(PartyService.class).getPartyTrendRq(req, this);
	}

}
