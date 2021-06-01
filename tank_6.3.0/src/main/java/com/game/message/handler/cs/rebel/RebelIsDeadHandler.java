package com.game.message.handler.cs.rebel;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.RebelIsDeadRq;
import com.game.service.RebelService;

public class RebelIsDeadHandler extends ClientHandler {

	@Override
	public void action() {
		RebelIsDeadRq req = msg.getExtension(RebelIsDeadRq.ext);
		getService(RebelService.class).rebelIsDead(req.getPos(), this);
	}
}
