package com.game.message.handler.cs.medal;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.UpMedalRq;
import com.game.service.MedalService;


public class UpMedalHandler extends ClientHandler {

	@Override
	public void action() {
		UpMedalRq req = msg.getExtension(UpMedalRq.ext);
		getService(MedalService.class).upMedal(req,this);
	}

}
