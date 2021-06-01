package com.game.message.handler.cs.energyStone;

import com.game.message.handler.ClientHandler;
import com.game.service.EnergyStoneService;

public class GetEnergyStoneInlayHandler extends ClientHandler {

	@Override
	public void action() {
		getService(EnergyStoneService.class).getEnergyStoneInlay(this);
	}
}
