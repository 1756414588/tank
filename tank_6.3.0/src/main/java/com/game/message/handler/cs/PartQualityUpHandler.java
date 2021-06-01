package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.PartQualityUpRq;
import com.game.service.PartService;

public class PartQualityUpHandler extends ClientHandler {

	@Override
	public void action() {
		PartQualityUpRq req = msg.getExtension(PartQualityUpRq.ext);
		getService(PartService.class).partQualityUp(req, this);
	}


}
