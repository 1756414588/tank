package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.DoPartCashRq;
import com.game.service.ActionCenterService;

public class DoPartCashHandler extends ClientHandler {

	@Override
	public void action() {
		DoPartCashRq req = msg.getExtension(DoPartCashRq.ext);
		getService(ActionCenterService.class).doPartCashRq(req, this);
	}

}
