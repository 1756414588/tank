package com.game.message.handler.cs.drill;

import com.game.message.handler.ClientHandler;
import com.game.service.DrillService;

public class DrillEnrollHandler extends ClientHandler {

	@Override
	public void action() {
		getService(DrillService.class).drillEnroll(this);
	}
}
