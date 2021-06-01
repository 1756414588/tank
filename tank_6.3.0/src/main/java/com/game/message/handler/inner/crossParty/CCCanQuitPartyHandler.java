package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCCanQuitPartyRs;
import com.game.service.PartyService;

public class CCCanQuitPartyHandler extends InnerHandler {

	@Override
	public void action() {
		getService(PartyService.class).canQuitParty(msg.getExtension(CCCanQuitPartyRs.ext), this);
	}

}
