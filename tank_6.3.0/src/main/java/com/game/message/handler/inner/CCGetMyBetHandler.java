package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetMyBetRs;
import com.game.service.CrossService;

public class CCGetMyBetHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).getMyBet(msg.getExtension(CCGetMyBetRs.ext),this);
	}

}
