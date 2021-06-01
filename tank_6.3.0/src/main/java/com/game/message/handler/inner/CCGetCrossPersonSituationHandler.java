package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCrossPersonSituationRs;
import com.game.service.CrossService;

public class CCGetCrossPersonSituationHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).getCrossPersonSituation(msg.getExtension(CCGetCrossPersonSituationRs.ext),this);
	}

}
