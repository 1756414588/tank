package com.game.message.handler.cs.medal;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.ExplodeMedalRq;
import com.game.service.MedalService;


public class ExplodeMedalHandler extends ClientHandler {

	@Override
	public void action() {
		ExplodeMedalRq req = msg.getExtension(ExplodeMedalRq.ext);
		getService(MedalService.class).explodeMedal(req,this);
	}

}
