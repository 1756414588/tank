package com.game.message.handler.cs.energyStone;

import com.game.message.handler.ClientHandler;
import com.game.service.AltarBossService;

public class FightAltarBossHandler extends ClientHandler {

	@Override
	public void action() {
		getService(AltarBossService.class).fightAltarBoss(this);
	}
}
