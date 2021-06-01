package com.game.message.handler.cs.medal;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.RefitMedalRq;
import com.game.service.MedalService;


public class RefitMedalHandler extends ClientHandler {

	@Override
	public void action() {
		RefitMedalRq req = msg.getExtension(RefitMedalRq.ext);
		getService(MedalService.class).refitMedal(req,this);
	}

}
