package com.game.message.handler.cs.medal;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.OnMedalRq;
import com.game.service.MedalService;


public class OnMedalHandler extends ClientHandler {

	@Override
	public void action() {
		OnMedalRq req = msg.getExtension(OnMedalRq.ext);
		getService(MedalService.class).onMedal(req,this);
	}

}
