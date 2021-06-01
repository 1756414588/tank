package com.game.message.handler.cs.energyStone;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.AllEnergyStoneRq;
import com.game.service.EnergyStoneService;

public class AllEnergyStoneHandler extends ClientHandler {

	@Override
	public void action() {
		//Auto-generated method stub
		AllEnergyStoneRq req = msg.getExtension(AllEnergyStoneRq.ext);
		getService(EnergyStoneService.class).allEnergyStone(req, this);
	}

}
