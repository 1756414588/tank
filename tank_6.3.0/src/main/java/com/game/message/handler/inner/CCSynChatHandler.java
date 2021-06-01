package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCSynChatRq;
import com.game.service.CrossService;

public class CCSynChatHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).rqSynChat(msg.getExtension(CCSynChatRq.ext),this);
	}

}
