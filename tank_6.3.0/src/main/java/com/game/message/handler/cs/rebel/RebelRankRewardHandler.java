package com.game.message.handler.cs.rebel;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.RebelRankRewardRq;
import com.game.service.RebelService;

public class RebelRankRewardHandler extends ClientHandler {

	@Override
	public void action() {
		RebelRankRewardRq rq = msg.getExtension(RebelRankRewardRq.ext);
		getService(RebelService.class).rebelRankReward(this, rq.getAwardType());
	}
}
