package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.M1a2RefitTankRq;
import com.game.service.ActionCenterService;

public class M1a2RefitTankHandler extends ClientHandler {

	@Override
	public void action() {
		M1a2RefitTankRq req = msg.getExtension(M1a2RefitTankRq.ext);
		getService(ActionCenterService.class).m1a2RefitTank(req, this);
	}

}
