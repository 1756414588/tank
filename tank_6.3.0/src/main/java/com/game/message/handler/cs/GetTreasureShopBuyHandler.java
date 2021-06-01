package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ShopService;

public class GetTreasureShopBuyHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ShopService.class).getTreasureShopBuy(this);
	}

}
