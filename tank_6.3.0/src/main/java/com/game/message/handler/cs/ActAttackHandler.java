package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.ActAttackRq;
import com.game.service.ActivityService;

public class ActAttackHandler extends ClientHandler {

	@Override
	public void action() {
		ActAttackRq req = msg.getExtension(ActAttackRq.ext);
		getService(ActivityService.class).actAttackRq(req, this);
	}

}
