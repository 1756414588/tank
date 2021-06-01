package com.game.message.handler.cs.drill;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.GetDrillRecordRq;
import com.game.service.DrillService;

public class GetDrillRecordHandler extends ClientHandler {

	@Override
	public void action() {
		GetDrillRecordRq req = msg.getExtension(GetDrillRecordRq.ext);
		int pageNum = 0;
		if(req.hasPage()) {
			pageNum = req.getPage();
		}
		getService(DrillService.class).getDrillRecord(req.getType(), req.getWhich(), pageNum, this);
	}
}
