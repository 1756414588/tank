package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.DoActHilarityPrayActionRq;
import com.game.service.ActionCenterService;

public class DoActHilarityPrayActionHandler extends ClientHandler{

	@Override
	public void action() {
		DoActHilarityPrayActionRq req = msg.getExtension(DoActHilarityPrayActionRq.ext);
		getService(ActionCenterService.class).doActHilarityPrayAction(req, this);
	}

}
