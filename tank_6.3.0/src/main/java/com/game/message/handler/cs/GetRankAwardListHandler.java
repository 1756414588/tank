package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.GetRankAwardListRq;
import com.game.service.ActionCenterService;

public class GetRankAwardListHandler extends ClientHandler {

	@Override
	public void action() {
		GetRankAwardListRq req = msg.getExtension(GetRankAwardListRq.ext);
		getService(ActionCenterService.class).getRankAwardListRq(req, this);
	}

}
