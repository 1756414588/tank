package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.FortressAppointRq;
import com.game.service.FortressWarService;

public class FortressAppointHandler extends ClientHandler {

	@Override
	public void action() {
		getService(FortressWarService.class).fortressAppoint(msg.getExtension(FortressAppointRq.ext),this);
	}

}
