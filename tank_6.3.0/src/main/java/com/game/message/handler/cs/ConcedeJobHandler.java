package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.ConcedeJobRq;
import com.game.service.PartyService;

public class ConcedeJobHandler extends ClientHandler {

	@Override
	public void action() {
		ConcedeJobRq req = msg.getExtension(ConcedeJobRq.ext);
		getService(PartyService.class).concedeJobRq(req, this);
	}

}
