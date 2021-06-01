package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.PartyctAwardRq;
import com.game.service.PartyService;

public class PartyctAwardHander extends ClientHandler{

	@Override
	public void action() {
		PartyctAwardRq req = msg.getExtension(PartyctAwardRq.ext);
		getService(PartyService.class).partyctAward(req, this);
	}

}
