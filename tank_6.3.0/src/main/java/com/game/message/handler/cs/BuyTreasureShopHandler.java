package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.BuyTreasureShopRq;
import com.game.service.ShopService;

public class BuyTreasureShopHandler extends ClientHandler {

	@Override
	public void action() {
		BuyTreasureShopRq req = msg.getExtension(BuyTreasureShopRq.ext);
		getService(ShopService.class).buyTreasureShop(req, this);
	}

}
