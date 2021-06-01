package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCPRankRs;
import com.game.service.CrossPartyService;

public class CCGetCPRankHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).getCPRank(msg.getExtension(CCGetCPRankRs.ext), this);
	}

}
