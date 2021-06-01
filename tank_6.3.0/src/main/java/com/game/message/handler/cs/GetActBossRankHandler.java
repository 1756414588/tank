package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.GetActBossRankRq;
import com.game.service.ActionCenterService;

public class GetActBossRankHandler extends ClientHandler {

	@Override
	public void action() {
		GetActBossRankRq req = msg.getExtension(GetActBossRankRq.ext);
		getService(ActionCenterService.class).getActBossRankRq(req.getRankType(),this);
	}
}
