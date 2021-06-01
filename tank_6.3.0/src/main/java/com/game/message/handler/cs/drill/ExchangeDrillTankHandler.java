package com.game.message.handler.cs.drill;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.ExchangeDrillTankRq;
import com.game.service.DrillService;

public class ExchangeDrillTankHandler extends ClientHandler {

	@Override
	public void action() {
		ExchangeDrillTankRq req = msg.getExtension(ExchangeDrillTankRq.ext);
		getService(DrillService.class).exchangeDrillTank(req.getTankId(), req.getCount(), this);
	}
}
