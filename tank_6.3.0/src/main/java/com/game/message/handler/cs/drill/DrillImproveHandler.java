package com.game.message.handler.cs.drill;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.DrillImproveRq;
import com.game.service.DrillService;

public class DrillImproveHandler extends ClientHandler {

	@Override
	public void action() {
		DrillImproveRq req = msg.getExtension(DrillImproveRq.ext);
		getService(DrillService.class).drillImprove(req.getBuffId(), this);
	}
}
