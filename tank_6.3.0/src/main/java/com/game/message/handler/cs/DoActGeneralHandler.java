package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.DoActGeneralRq;
import com.game.service.ActionCenterService;

public class DoActGeneralHandler extends ClientHandler {

	@Override
	public void action() {
		DoActGeneralRq req = msg.getExtension(DoActGeneralRq.ext);
		getService(ActionCenterService.class).doActGeneralRq(req, this);
	}

}
