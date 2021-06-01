package com.game.message.handler.cs.corss;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.BetBattleRq;
import com.game.service.CrossService;

public class BetBattleHandler extends ClientHandler {

	@Override
	public void action() {
		getService(CrossService.class).betBattle(msg.getExtension(BetBattleRq.ext), this);
	}

}
