package com.game.message.handler.cs.drill;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.GetDrillFightReportRq;
import com.game.service.DrillService;

public class GetDrillFightReportHandler extends ClientHandler {

	@Override
	public void action() {
		GetDrillFightReportRq req = msg.getExtension(GetDrillFightReportRq.ext);
		getService(DrillService.class).getDrillFightReport(req.getReportKey(), this);
	}
}
