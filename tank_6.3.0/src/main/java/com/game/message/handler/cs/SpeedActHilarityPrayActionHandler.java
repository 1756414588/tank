package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.SpeedActHilarityPrayActionRq;
import com.game.service.ActionCenterService;

public class SpeedActHilarityPrayActionHandler extends ClientHandler{

	@Override
	public void action() {
		SpeedActHilarityPrayActionRq req = msg.getExtension(SpeedActHilarityPrayActionRq.ext);
		getService(ActionCenterService.class).speedActHilarityPrayAction(req, this);
	}

}
