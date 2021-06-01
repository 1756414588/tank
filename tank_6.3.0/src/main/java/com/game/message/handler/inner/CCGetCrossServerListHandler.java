package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCrossServerListRs;
import com.game.service.CrossService;

public class CCGetCrossServerListHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).getCrossServerList(msg.getExtension(CCGetCrossServerListRs.ext), this);
	}
}
