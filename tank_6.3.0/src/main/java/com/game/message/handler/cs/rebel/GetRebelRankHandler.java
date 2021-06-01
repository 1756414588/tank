package com.game.message.handler.cs.rebel;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.GetRebelRankRq;
import com.game.service.RebelService;

public class GetRebelRankHandler extends ClientHandler {

	@Override
	public void action() {
		GetRebelRankRq req = msg.getExtension(GetRebelRankRq.ext);
		getService(RebelService.class).getRebelRank(req.getRankType(), req.getPage(), this);
	}
}
