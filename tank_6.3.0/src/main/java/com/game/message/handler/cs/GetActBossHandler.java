package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.GetActBossRq;
import com.game.service.ActionCenterService;

public class GetActBossHandler extends ClientHandler {

	@Override
	public void action() {
		GetActBossRq req = msg.getExtension(GetActBossRq.ext);
		getService(ActionCenterService.class).getActBoss(req.getType(),this);
	}
}
