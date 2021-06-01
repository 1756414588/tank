package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.AttackActBossRq;
import com.game.service.ActionCenterService;

public class AttackActBossHandler extends ClientHandler {

	@Override
	public void action() {
		AttackActBossRq req = msg.getExtension(AttackActBossRq.ext);
		getService(ActionCenterService.class).attackActBoss(req.getUseId(),req.getUseGold(),this);
	}
}
