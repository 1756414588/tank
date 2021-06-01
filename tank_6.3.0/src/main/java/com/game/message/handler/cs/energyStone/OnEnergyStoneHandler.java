package com.game.message.handler.cs.energyStone;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.OnEnergyStoneRq;
import com.game.service.EnergyStoneService;

public class OnEnergyStoneHandler extends ClientHandler {

	@Override
	public void action() {
		OnEnergyStoneRq req = msg.getExtension(OnEnergyStoneRq.ext);

		getService(EnergyStoneService.class).onEnergyStone(req, this);
	}
}
