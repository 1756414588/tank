package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCCancelCrossRegRs;
import com.game.service.CrossService;

public class CCCancelCrossRegHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).cancelCrossReg(msg.getCode(),msg.getExtension(CCCancelCrossRegRs.ext),this);
	}

}
