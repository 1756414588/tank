package com.game.message.handler.cs.drill;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.DrillRewardRq;
import com.game.service.DrillService;

public class DrillRewardHandler extends ClientHandler {

	@Override
	public void action() {
		DrillRewardRq req = msg.getExtension(DrillRewardRq.ext);
		getService(DrillService.class).drillReward(req.getRewardType(), this);
	}
}
