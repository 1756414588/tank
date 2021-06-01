package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.SendPartyAmyPropRq;
import com.game.service.PartyService;

public class SendPartyAmyPropHandler extends ClientHandler {

	@Override
	public void action() {
		SendPartyAmyPropRq req = msg.getExtension(SendPartyAmyPropRq.ext);
		getService(PartyService.class).sendPartyAmyPropRq(req, this);
	}

}
