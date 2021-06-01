package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.DoActGambleRq;
import com.game.service.ActionCenterService;

public class DoActGambleHandler extends ClientHandler {

	@Override
	public void action() {
		DoActGambleRq req = msg.getExtension(DoActGambleRq.ext);
		getService(ActionCenterService.class).doActGambleRq(req, this);
	}

}
