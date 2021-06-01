package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.GetActivityAwardRq;
import com.game.service.ActivityService;

public class GetActivityAwardHandler extends ClientHandler {

	@Override
	public void action() {
		GetActivityAwardRq req = msg.getExtension(GetActivityAwardRq.ext);
		getService(ActivityService.class).getActivityAward(req, this);
	}

}
