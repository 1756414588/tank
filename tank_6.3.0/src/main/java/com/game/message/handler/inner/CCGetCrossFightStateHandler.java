package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCrossFightStateRs;
import com.game.service.CrossService;

public class CCGetCrossFightStateHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).getCrossFightState(msg.getExtension(CCGetCrossFightStateRs.ext),this);
	}

}
