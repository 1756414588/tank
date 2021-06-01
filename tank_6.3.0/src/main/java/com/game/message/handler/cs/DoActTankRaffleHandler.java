package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.DoActTankRaffleRq;
import com.game.service.ActionCenterService;

public class DoActTankRaffleHandler extends ClientHandler {

	@Override
	public void action() {
		DoActTankRaffleRq req = msg.getExtension(DoActTankRaffleRq.ext);
		getService(ActionCenterService.class).doActTankRaffleRq(req, this);
	}

}
