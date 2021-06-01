package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.GetPartyRankRq;
import com.game.service.PartyService;

public class GetPartyRankHandler extends ClientHandler {

	@Override
	public void action() {
		GetPartyRankRq req = msg.getExtension(GetPartyRankRq.ext);
		getService(PartyService.class).getPartyRank(req, this);
	}

}
