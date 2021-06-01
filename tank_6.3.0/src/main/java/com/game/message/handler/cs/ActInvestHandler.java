package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.ActInvestRq;
import com.game.service.ActivityService;

public class ActInvestHandler extends ClientHandler {

	@Override
	public void action() {
		ActInvestRq req = msg.getExtension(ActInvestRq.ext);
		getService(ActivityService.class).actInvestRq(req,this);
	}

}
