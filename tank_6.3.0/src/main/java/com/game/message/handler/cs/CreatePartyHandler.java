package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.CreatePartyRq;
import com.game.service.PartyService;

public class CreatePartyHandler extends ClientHandler {

	@Override
	public void action() {
		CreatePartyRq req = msg.getExtension(CreatePartyRq.ext);
		getService(PartyService.class).createPartyRq(req, this);
	}

}
