package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.RefshPartCashRq;
import com.game.service.ActionCenterService;

public class RefshPartCashHandler extends ClientHandler {

	@Override
	public void action() {
		RefshPartCashRq req = msg.getExtension(RefshPartCashRq.ext);
		getService(ActionCenterService.class).refshPartCashRq(req, this);
	}

}
