package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCrossPartyServerListRs;
import com.game.service.CrossPartyService;

public class CCGetCrossPartyServerListHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).getCrossPartyServerList(msg.getExtension(CCGetCrossPartyServerListRs.ext), this);
	}

}
