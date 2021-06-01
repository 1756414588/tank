package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.GetActBeeRankRq;
import com.game.service.ActionCenterService;

public class GetActBeeRankHandler extends ClientHandler {

	@Override
	public void action() {
		GetActBeeRankRq req = msg.getExtension(GetActBeeRankRq.ext);
		getService(ActionCenterService.class).getActBeeRankRq(req, this);
	}

}
