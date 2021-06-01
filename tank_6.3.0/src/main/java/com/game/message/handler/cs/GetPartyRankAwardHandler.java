package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.GetPartyRankAwardRq;
import com.game.service.ActionCenterService;

public class GetPartyRankAwardHandler extends ClientHandler {

	@Override
	public void action() {
		GetPartyRankAwardRq req = msg.getExtension(GetPartyRankAwardRq.ext);
		getService(ActionCenterService.class).getPartyRankAwardRq(req, this);
	}

}
