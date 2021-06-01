package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.ReceiveActHilarityPrayRq;
import com.game.service.ActionCenterService;

public class RecevieActHilarityPrayHandler extends ClientHandler{

	@Override
	public void action() {
		ReceiveActHilarityPrayRq req = msg.getExtension(ReceiveActHilarityPrayRq.ext);
		getService(ActionCenterService.class).receiveActHilarityPray(req, this);
	}

}
