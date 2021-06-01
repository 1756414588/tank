package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.ActCostGoldRq;
import com.game.service.ActivityService;

public class ActCostGoldHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActivityService.class).actCostGoldRq(msg.getExtension(ActCostGoldRq.ext), this);
	}

}
