package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.GetFortressFightReportRq;
import com.game.service.FortressWarService;

public class GetFortressFightReportHandler extends ClientHandler {

	@Override
	public void action() {
		getService(FortressWarService.class).getFortressFightReport(msg.getExtension(GetFortressFightReportRq.ext),this);
	}

}
