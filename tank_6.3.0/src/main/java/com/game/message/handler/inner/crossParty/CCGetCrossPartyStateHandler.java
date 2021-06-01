package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCrossPartyStateRs;
import com.game.service.CrossPartyService;

public class CCGetCrossPartyStateHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).getCrossPartyState(msg.getExtension(CCGetCrossPartyStateRs.ext),this);
	}

}
