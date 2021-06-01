package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.DoActM1a2Rq;
import com.game.service.ActionCenterService;

public class DoActM1a2Handler extends ClientHandler {

	@Override
	public void action() {
		DoActM1a2Rq req = msg.getExtension(DoActM1a2Rq.ext);
		getService(ActionCenterService.class).doActM1a2(req, this);
	}

}
