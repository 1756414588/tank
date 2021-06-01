package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.DoLotteryRq;
import com.game.service.LotteryService;

public class DoLotteryHandler extends ClientHandler {

	@Override
	public void action() {
		//Auto-generated method stub
		DoLotteryRq req = msg.getExtension(DoLotteryRq.ext);
		getService(LotteryService.class).doLottery(req, this);
	}

}
