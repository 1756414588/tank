package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCSetCrossFormRs;
import com.game.service.CrossService;

public class CCSetCrossFormHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).setCrossForm(msg.getCode(),msg.getExtension(CCSetCrossFormRs.ext),this);
	}

}
