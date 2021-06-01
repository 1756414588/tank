package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCExchangeCrossShopRs;
import com.game.service.CrossService;

public class CCExchangeCrossShopHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).exchangeCrossShop(msg.getCode(), msg.getExtension(CCExchangeCrossShopRs.ext), this);
	}

}
