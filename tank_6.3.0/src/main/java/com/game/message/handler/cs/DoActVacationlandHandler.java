package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.DoActVacationlandRq;
import com.game.service.ActionCenterService;

public class DoActVacationlandHandler extends ClientHandler {

	@Override
	public void action() {
		DoActVacationlandRq req = msg.getExtension(DoActVacationlandRq.ext);
		getService(ActionCenterService.class).doActVacationlandRq(req, this);
	}

}
