package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.GetActAmyRebateRq;
import com.game.service.ActionCenterService;

public class GetActAmyRebateHandler extends ClientHandler {

	@Override
	public void action() {
		GetActAmyRebateRq req = msg.getExtension(GetActAmyRebateRq.ext);
		getService(ActionCenterService.class).getActAmyRebate(req, this);
	}

}
