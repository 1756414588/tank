package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.BuyPartyShopRq;
import com.game.service.PartyService;

public class BuyPartyShopHandler extends ClientHandler {

	@Override
	public void action() {
		BuyPartyShopRq req = msg.getExtension(BuyPartyShopRq.ext);
		getService(PartyService.class).buyPartyShopRq(req, this);
	}

}
