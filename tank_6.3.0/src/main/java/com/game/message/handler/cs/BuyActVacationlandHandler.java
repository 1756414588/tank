package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.BuyActVacationlandRq;
import com.game.service.ActionCenterService;

public class BuyActVacationlandHandler extends ClientHandler {

	@Override
	public void action() {
		BuyActVacationlandRq req = msg.getExtension(BuyActVacationlandRq.ext);
		getService(ActionCenterService.class).buyActVacationlandRq(req, this);
	}

}
