package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.LotteryService;

public class GetLotteryEquipHandler extends ClientHandler {

	@Override
	public void action() {
		getService(LotteryService.class).GetLotteryEquip(this);
	}

}
