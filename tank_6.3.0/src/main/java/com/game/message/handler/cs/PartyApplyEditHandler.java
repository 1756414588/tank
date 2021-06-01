package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.PartyApplyEditRq;
import com.game.service.PartyService;

public class PartyApplyEditHandler extends ClientHandler {

	@Override
	public void action() {
		PartyApplyEditRq req = msg.getExtension(PartyApplyEditRq.ext);
		getService(PartyService.class).partyApplyEditRq(req, this);
	}

}
