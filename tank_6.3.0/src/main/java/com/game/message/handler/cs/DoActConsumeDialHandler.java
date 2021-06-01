package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.DoActConsumeDialRq;
import com.game.service.ActionCenterService;

public class DoActConsumeDialHandler extends ClientHandler {

	@Override
	public void action() {
		DoActConsumeDialRq req = msg.getExtension(DoActConsumeDialRq.ext);
		getService(ActionCenterService.class).doActConsumeDialRq(req, this);
	}

}
