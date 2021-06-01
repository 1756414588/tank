package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCSynCrossFameRq;
import com.game.service.CrossService;

public class CCSynCrossFameHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).rqSynCrossFame(msg.getExtension(CCSynCrossFameRq.ext),this);
	}

}
