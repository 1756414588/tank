package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.PartyApplyRq;
import com.game.service.PartyService;

public class PartyApplyHandler extends ClientHandler {

	@Override
	public void action() {
		PartyApplyRq req = msg.getExtension(PartyApplyRq.ext);
		getService(PartyService.class).partyApplyRq(req, this);
	}

}
