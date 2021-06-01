package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCPTrendRs;
import com.game.service.CrossPartyService;

public class CCGetCPTrendHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).getCPTrend(msg.getExtension(CCGetCPTrendRs.ext), this);
	}

}
