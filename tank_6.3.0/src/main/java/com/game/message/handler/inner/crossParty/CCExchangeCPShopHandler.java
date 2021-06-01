package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCExchangeCPShopRs;
import com.game.service.CrossPartyService;

public class CCExchangeCPShopHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).exchangeCPShop(msg.getCode(), msg.getExtension(CCExchangeCPShopRs.ext), this);
	}

}
