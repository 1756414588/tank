package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.DoActPayTurntableRq;
import com.game.service.ActionCenterService;

public class DoActPayTurntableHandler extends ClientHandler {

	@Override
	public void action() {
		DoActPayTurntableRq req = msg.getExtension(DoActPayTurntableRq.ext);
		getService(ActionCenterService.class).doActPayTurntableRq(req, this);
	}

}
