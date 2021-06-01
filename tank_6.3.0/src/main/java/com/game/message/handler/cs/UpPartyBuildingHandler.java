package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.UpPartyBuildingRq;
import com.game.service.PartyService;

public class UpPartyBuildingHandler extends ClientHandler {

	@Override
	public void action() {
		UpPartyBuildingRq req = msg.getExtension(UpPartyBuildingRq.ext);
		getService(PartyService.class).upPartyBuildingRq(req, this);
	}

}
