package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.DoActNewRaffleRq;
import com.game.service.ActionCenterService;

public class DoActNewRaffleHandler extends ClientHandler {

	@Override
	public void action() {
		DoActNewRaffleRq req = msg.getExtension(DoActNewRaffleRq.ext);
		getService(ActionCenterService.class).doActNewRaffleRq(req, this);
	}

}
