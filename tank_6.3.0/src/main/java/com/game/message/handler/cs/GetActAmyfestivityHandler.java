package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.GetActAmyfestivityRq;
import com.game.service.ActionCenterService;

public class GetActAmyfestivityHandler extends ClientHandler {

	@Override
	public void action() {
		GetActAmyfestivityRq req = msg.getExtension(GetActAmyfestivityRq.ext);
		getService(ActionCenterService.class).getActAmyfestivityRq(req, this);
	}

}
