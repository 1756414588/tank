package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCSynCrossPartyStateRq;
import com.game.service.CrossPartyService;

public class CCSynCrossPartyStateHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).synCrossPartyState(msg.getExtension(CCSynCrossPartyStateRq.ext), this);
	}

}
