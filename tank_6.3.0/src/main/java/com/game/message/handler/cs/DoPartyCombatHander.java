package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.DoPartyCombatRq;
import com.game.service.PartyService;

public class DoPartyCombatHander extends ClientHandler{

	@Override
	public void action() {
		DoPartyCombatRq req = msg.getExtension(DoPartyCombatRq.ext);
		getService(PartyService.class).doPartyCombat(req, this);
	}

}
