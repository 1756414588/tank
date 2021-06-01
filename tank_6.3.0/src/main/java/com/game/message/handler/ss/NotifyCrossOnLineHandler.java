package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb.NotifyCrossOnLineRq;
import com.game.service.CrossService;

public class NotifyCrossOnLineHandler extends ServerHandler {

	@Override
	public void action() {
		getService(CrossService.class).notifyCrossOnLine(msg.getExtension(NotifyCrossOnLineRq.ext), this);
	}

}
