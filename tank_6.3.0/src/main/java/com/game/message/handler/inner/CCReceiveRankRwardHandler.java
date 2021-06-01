package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCReceiveRankRwardRs;
import com.game.service.CrossService;

public class CCReceiveRankRwardHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).receiveRankRward(msg.getCode(), msg.getExtension(CCReceiveRankRwardRs.ext), this);
	}

}
