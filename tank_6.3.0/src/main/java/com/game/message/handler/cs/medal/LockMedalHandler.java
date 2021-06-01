package com.game.message.handler.cs.medal;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.LockMedalRq;
import com.game.service.MedalService;


public class LockMedalHandler extends ClientHandler {

	@Override
	public void action() {
		LockMedalRq req = msg.getExtension(LockMedalRq.ext);
		getService(MedalService.class).lockMedal(req,this);
	}

}
