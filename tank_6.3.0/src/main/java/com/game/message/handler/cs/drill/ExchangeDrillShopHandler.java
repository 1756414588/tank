package com.game.message.handler.cs.drill;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.ExchangeDrillShopRq;
import com.game.service.DrillService;

public class ExchangeDrillShopHandler extends ClientHandler {

	@Override
	public void action() {
		ExchangeDrillShopRq req = msg.getExtension(ExchangeDrillShopRq.ext);
		getService(DrillService.class).exchangeDrillShop(req.getShopId(), req.getCount(), this);
	}
}
