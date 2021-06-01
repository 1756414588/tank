package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.DoActAmyRebateRq;
import com.game.service.ActionCenterService;

public class DoActAmyRebateHandler extends ClientHandler {

	@Override
	public void action() {
		DoActAmyRebateRq req = msg.getExtension(DoActAmyRebateRq.ext);
		getService(ActionCenterService.class).doActAmyRebateRq(req, this);
	}

}
