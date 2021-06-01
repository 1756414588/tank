package com.game.message.handler.cs.energyStone;

import com.game.message.handler.ClientHandler;
import com.game.service.AltarBossService;

public class GetAltarBossHurtRankHandler extends ClientHandler {

	@Override
	public void action() {
		getService(AltarBossService.class).getAltarBossHurtRank(this);
	}
}
