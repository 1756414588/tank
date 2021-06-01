package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCBetBattleRs;
import com.game.service.CrossService;

public class CCBetBattleHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).betBattle(msg.getCode(),msg.getExtension(CCBetBattleRs.ext),this);		
	}

}
