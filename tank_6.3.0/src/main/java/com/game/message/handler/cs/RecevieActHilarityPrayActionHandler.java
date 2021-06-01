package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.ReceiveActHilarityPrayActionRq;
import com.game.service.ActionCenterService;

public class RecevieActHilarityPrayActionHandler extends ClientHandler{

	@Override
	public void action() {
		ReceiveActHilarityPrayActionRq req = msg.getExtension(ReceiveActHilarityPrayActionRq.ext);
		getService(ActionCenterService.class).receiveActHilarityPrayAction(req, this);
	}

}
