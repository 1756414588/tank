package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.DoActTechRq;
import com.game.service.ActionCenterService;

public class DoActTechHandler extends ClientHandler {

	@Override
	public void action() {
		DoActTechRq req = msg.getExtension(DoActTechRq.ext);
		getService(ActionCenterService.class).doActTechRq(req, this);
	}

}
