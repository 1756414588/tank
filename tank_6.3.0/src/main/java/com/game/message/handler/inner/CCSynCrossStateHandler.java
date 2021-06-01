package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCSynCrossStateRq;
import com.game.service.CrossService;

public class CCSynCrossStateHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).rqSynCrossState(msg.getExtension(CCSynCrossStateRq.ext),this);
	}

}
