package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCReceiveBetRs;
import com.game.service.CrossService;

public class CCReceiveBetHanlder extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).receiveBet(msg.getCode(),msg.getExtension(CCReceiveBetRs.ext),this);
	}

}
