package com.game.message.handler.cs.energyStone;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.CombineEnergyStoneRq;
import com.game.service.EnergyStoneService;

public class CombineEnergyStoneHandler extends ClientHandler {

	@Override
	public void action() {
		CombineEnergyStoneRq req = msg.getExtension(CombineEnergyStoneRq.ext);

		getService(EnergyStoneService.class).combineEnergyStone(req, this);
	}
}
