package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCSynCPSituationRq;
import com.game.service.CrossPartyService;

public class CCSynCPSituationHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).synCPSituation(msg.getExtension(CCSynCPSituationRq.ext));
	}

}
