package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCrossShopRs;
import com.game.service.CrossService;

public class CCGetCrossShopHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).getCrossShop(msg.getCode(), msg.getExtension(CCGetCrossShopRs.ext), this);
	}

}
