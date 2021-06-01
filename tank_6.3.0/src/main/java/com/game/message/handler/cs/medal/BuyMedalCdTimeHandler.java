package com.game.message.handler.cs.medal;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.BuyMedalCdTimeRq;
import com.game.service.MedalService;


public class BuyMedalCdTimeHandler extends ClientHandler {

	@Override
	public void action() {
		BuyMedalCdTimeRq req = msg.getExtension(BuyMedalCdTimeRq.ext);
		getService(MedalService.class).buyMedalCdTime(req,this);
	}

}
