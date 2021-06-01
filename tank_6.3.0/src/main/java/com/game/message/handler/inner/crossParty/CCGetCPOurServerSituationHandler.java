package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCPOurServerSituationRs;
import com.game.service.CrossPartyService;

public class CCGetCPOurServerSituationHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).getCPOurServerSituation(msg.getExtension(CCGetCPOurServerSituationRs.ext), this);
	}

}
