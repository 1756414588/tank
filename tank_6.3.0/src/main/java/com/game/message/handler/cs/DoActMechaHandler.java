package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.DoActMechaRq;
import com.game.service.ActionCenterService;

public class DoActMechaHandler extends ClientHandler {

	@Override
	public void action() {
		DoActMechaRq req = msg.getExtension(DoActMechaRq.ext);
		getService(ActionCenterService.class).doActMechaRq(req, this);
	}

}
