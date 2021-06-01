package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.GetRankAwardRq;
import com.game.service.ActionCenterService;

public class GetRankAwardHandler extends ClientHandler {

	@Override
	public void action() {
		GetRankAwardRq req = msg.getExtension(GetRankAwardRq.ext);
		getService(ActionCenterService.class).getRankAwardRq(req, this);
	}

}
