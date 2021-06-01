package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCPFormRs;
import com.game.service.CrossPartyService;

public class CCGetCPFormHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).getCPForm(msg.getCode(),msg.getExtension(CCGetCPFormRs.ext), this);
	}

}
