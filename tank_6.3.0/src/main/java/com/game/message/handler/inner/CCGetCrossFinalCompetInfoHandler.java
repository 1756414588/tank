package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCrossFinalCompetInfoRs;
import com.game.service.CrossService;

public class CCGetCrossFinalCompetInfoHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).getCrossFinalCompetInfo(msg.getExtension(CCGetCrossFinalCompetInfoRs.ext),this);
	}

}
