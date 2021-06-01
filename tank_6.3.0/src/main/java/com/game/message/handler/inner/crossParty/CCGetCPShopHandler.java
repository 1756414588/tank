package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCPShopRs;
import com.game.service.CrossPartyService;

public class CCGetCPShopHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).getCPShop(msg.getExtension(CCGetCPShopRs.ext), this);
	}

}
