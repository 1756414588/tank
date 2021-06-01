package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.CleanMemberRq;
import com.game.service.PartyService;

public class CleanMemberHandler extends ClientHandler {

	@Override
	public void action() {
		CleanMemberRq req = msg.getExtension(CleanMemberRq.ext);
		getService(PartyService.class).cleanMemberRq(req, this);
	}

}
