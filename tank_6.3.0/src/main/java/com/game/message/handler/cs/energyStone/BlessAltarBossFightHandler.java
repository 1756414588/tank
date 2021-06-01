package com.game.message.handler.cs.energyStone;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.BlessAltarBossFightRq;
import com.game.service.AltarBossService;

public class BlessAltarBossFightHandler extends ClientHandler {

	@Override
	public void action() {
		BlessAltarBossFightRq req = msg.getExtension(BlessAltarBossFightRq.ext);

		getService(AltarBossService.class).blessAltarBossFight(req.getIndex(), this);
	}
}
