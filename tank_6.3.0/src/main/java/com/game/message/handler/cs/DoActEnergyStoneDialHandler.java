package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.DoActEnergyStoneDialRq;
import com.game.service.ActionCenterService;

public class DoActEnergyStoneDialHandler extends ClientHandler {

	@Override
	public void action() {
		DoActEnergyStoneDialRq req = msg.getExtension(DoActEnergyStoneDialRq.ext);
		getService(ActionCenterService.class).doActEnergyStoneDialRq(req, this);
	}

}
