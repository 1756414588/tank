package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCrossTrendRs;
import com.game.service.CrossService;

public class CCGetCrossTrendHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).getCrossTrend(msg.getExtension(CCGetCrossTrendRs.ext),this);
	}

}
