package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.GetActM1a2Rq;
import com.game.service.ActionCenterService;

public class GetActM1a2Handler extends ClientHandler {

	@Override
	public void action() {
		GetActM1a2Rq req = msg.getExtension(GetActM1a2Rq.ext);
		getService(ActionCenterService.class).getActM1a2(req, this);
	}

}
