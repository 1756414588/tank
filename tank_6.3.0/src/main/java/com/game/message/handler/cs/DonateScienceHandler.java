package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.DonateScienceRq;
import com.game.service.PartyService;

public class DonateScienceHandler extends ClientHandler {

	@Override
	public void action() {
		DonateScienceRq req = msg.getExtension(DonateScienceRq.ext);
		getService(PartyService.class).donateScience(req, this);
	}

}
