package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.DoActPartDialRq;
import com.game.service.ActionCenterService;

public class DoActPartDialHandler extends ClientHandler {

	@Override
	public void action() {
		DoActPartDialRq req = msg.getExtension(DoActPartDialRq.ext);
		getService(ActionCenterService.class).doActPartDialRq(req, this);
	}

}
