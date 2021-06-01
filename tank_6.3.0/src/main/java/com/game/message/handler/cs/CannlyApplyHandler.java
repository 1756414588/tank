package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.CannlyApplyRq;
import com.game.service.PartyService;

public class CannlyApplyHandler extends ClientHandler {

	@Override
	public void action() {
		CannlyApplyRq req = msg.getExtension(CannlyApplyRq.ext);
		getService(PartyService.class).cannlyApplyRq(req, this);
	}

}
