package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.LockNewRaffleRq;
import com.game.service.ActionCenterService;

public class LockNewRaffleHandler extends ClientHandler {

	@Override
	public void action() {
		LockNewRaffleRq req = msg.getExtension(LockNewRaffleRq.ext);
		getService(ActionCenterService.class).lockNewRaffleRq(req, this);
	}

}
