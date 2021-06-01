package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCrossRegInfoRs;
import com.game.service.CrossService;

public class CCGetCrossRegInfoHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).getCrossRegInfo(msg.getExtension(CCGetCrossRegInfoRs.ext),this);
	}

}
