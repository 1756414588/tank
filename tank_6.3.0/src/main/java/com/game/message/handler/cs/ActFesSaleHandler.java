package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.ActFesSaleRq;
import com.game.service.ActivityService;

public class ActFesSaleHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActivityService.class).actFesSaleRq(msg.getExtension(ActFesSaleRq.ext), this);
	}

}
