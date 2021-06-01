package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCSynMailRq;
import com.game.service.CrossService;

public class CCSynMailHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).rqSynMail(msg.getExtension(CCSynMailRq.ext),this);
	}

}
