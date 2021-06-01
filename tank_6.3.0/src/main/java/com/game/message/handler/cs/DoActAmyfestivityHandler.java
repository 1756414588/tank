package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.DoActAmyfestivityRq;
import com.game.service.ActionCenterService;

public class DoActAmyfestivityHandler extends ClientHandler {

	@Override
	public void action() {
		DoActAmyfestivityRq req = msg.getExtension(DoActAmyfestivityRq.ext);
		getService(ActionCenterService.class).doActAmyfestivityRq(req, this);
	}

}
