package com.game.message.handler.cs.drill;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.GetDrillRankRq;
import com.game.service.DrillService;

public class GetDrillRankHandler extends ClientHandler {

	@Override
	public void action() {
		GetDrillRankRq req = msg.getExtension(GetDrillRankRq.ext);
		getService(DrillService.class).getDrillRank(req.getRankType(), this);
	}
}
