package com.game.message.handler.cs.medal;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.CombineMedalRq;
import com.game.service.MedalService;


public class CombineMedalHandler extends ClientHandler {

	@Override
	public void action() {
		CombineMedalRq req = msg.getExtension(CombineMedalRq.ext);
		getService(MedalService.class).combineMedal(req,this);
	}

}
