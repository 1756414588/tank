package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCrossKnockCompetInfoRs;
import com.game.service.CrossService;

public class CCGetCrossKnockCompetInfoHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).getCrossKnockCompetInfo(msg.getExtension(CCGetCrossKnockCompetInfoRs.ext),this);
	}

}
