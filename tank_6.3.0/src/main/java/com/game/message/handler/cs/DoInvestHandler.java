package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.DoInvestRq;
import com.game.service.ActivityService;

public class DoInvestHandler extends ClientHandler {

	@Override
	public void action() {
		DoInvestRq req = msg.getExtension(DoInvestRq.ext);
		getService(ActivityService.class).doInvestRq(req,this);
	}

}
