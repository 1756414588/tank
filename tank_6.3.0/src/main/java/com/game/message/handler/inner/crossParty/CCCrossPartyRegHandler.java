package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCCrossPartyRegRs;
import com.game.service.CrossPartyService;

public class CCCrossPartyRegHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).crossPartyReg(msg.getCode(),msg.getExtension(CCCrossPartyRegRs.ext), this);
	}

}
