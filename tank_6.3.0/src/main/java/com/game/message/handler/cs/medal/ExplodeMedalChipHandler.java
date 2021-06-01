package com.game.message.handler.cs.medal;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.ExplodeMedalChipRq;
import com.game.service.MedalService;


public class ExplodeMedalChipHandler extends ClientHandler {

	@Override
	public void action() {
		ExplodeMedalChipRq req = msg.getExtension(ExplodeMedalChipRq.ext);
		getService(MedalService.class).explodeMedalChip(req,this);
	}

}
