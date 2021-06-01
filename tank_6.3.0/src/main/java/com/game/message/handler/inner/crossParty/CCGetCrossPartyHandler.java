package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCrossPartyRs;
import com.game.service.CrossPartyService;

public class CCGetCrossPartyHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).getCrossParty(msg.getExtension(CCGetCrossPartyRs.ext), this);
	}

}
