package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.GetActBeeRq;
import com.game.service.ActionCenterService;

public class GetActBeeHandler extends ClientHandler {

	@Override
	public void action() {
		GetActBeeRq req = msg.getExtension(GetActBeeRq.ext);
		getService(ActionCenterService.class).getActBeeRq(req, this);
	}

}
