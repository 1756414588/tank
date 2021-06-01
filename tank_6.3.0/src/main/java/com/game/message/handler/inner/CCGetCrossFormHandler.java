package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCrossFormRs;
import com.game.service.CrossService;

public class CCGetCrossFormHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).getCrossForm(msg.getCode(),msg.getExtension(CCGetCrossFormRs.ext),this);
	}

}
