package com.game.message.handler.cs.energyStone;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.SetAltarBossAutoFightRq;
import com.game.service.AltarBossService;

public class SetAltarBossAutoFightHandler extends ClientHandler {

	@Override
	public void action() {
		SetAltarBossAutoFightRq req = msg.getExtension(SetAltarBossAutoFightRq.ext);

		getService(AltarBossService.class).setAltarBossAutoFight(req.getAutoFight(), this);
	}
}
