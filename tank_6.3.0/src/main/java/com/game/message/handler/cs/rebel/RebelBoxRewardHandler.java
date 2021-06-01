package com.game.message.handler.cs.rebel;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.GetRebelBoxAwardRq;
import com.game.service.RebelService;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class RebelBoxRewardHandler extends ClientHandler {

	@Override
	public void action() {
		GetRebelBoxAwardRq rq = msg.getExtension(GetRebelBoxAwardRq.ext);
		getService(RebelService.class).getRebelBoxReward(this, rq.getPos());
	}

}
