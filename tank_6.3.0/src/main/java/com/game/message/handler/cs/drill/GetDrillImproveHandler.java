package com.game.message.handler.cs.drill;

import com.game.message.handler.ClientHandler;
import com.game.service.DrillService;

public class GetDrillImproveHandler extends ClientHandler {

	@Override
	public void action() {
		getService(DrillService.class).getDrillImprove(this);
	}
}
