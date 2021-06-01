package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.SetPartyJobRq;
import com.game.service.PartyService;

public class SetPartyJobHandler extends ClientHandler {

	@Override
	public void action() {
		SetPartyJobRq req = msg.getExtension(SetPartyJobRq.ext);
		getService(PartyService.class).setPartyJobRq(req, this);
	}

}
