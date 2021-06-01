package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCPMyRegInfoRs;
import com.game.service.CrossPartyService;

public class CCGetCPMyRegInfoHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).getCPMyRegInfo(msg.getExtension(CCGetCPMyRegInfoRs.ext), this);
	}

}
