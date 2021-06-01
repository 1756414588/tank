package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCPReportRs;
import com.game.service.CrossPartyService;

public class CCGetCPReportHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).getCPReport(msg.getExtension(CCGetCPReportRs.ext), this);
	}

}
