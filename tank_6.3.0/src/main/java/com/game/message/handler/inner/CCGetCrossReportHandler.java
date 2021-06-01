package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCrossReportRs;
import com.game.service.CrossService;

public class CCGetCrossReportHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).getCrossReport(msg.getCode(),msg.getExtension(CCGetCrossReportRs.ext),this);
	}

}
