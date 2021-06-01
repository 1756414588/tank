package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.TankCarnivalRewardRq;
import com.game.service.ActionCenterService;

public class TankCarnivalRewardHandler extends ClientHandler {

	@Override
	public void action() {
		TankCarnivalRewardRq req = msg.getExtension(TankCarnivalRewardRq.ext);
		getService(ActionCenterService.class).tankCarnivalReward(req, this);
	}

}
