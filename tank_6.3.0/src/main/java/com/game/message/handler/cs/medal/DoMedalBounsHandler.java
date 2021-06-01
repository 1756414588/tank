package com.game.message.handler.cs.medal;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.DoMedalBounsRq;
import com.game.service.MedalService;

public class DoMedalBounsHandler extends ClientHandler {

	@Override
	public void action() {
		DoMedalBounsRq req = msg.getExtension(DoMedalBounsRq.ext);
		getService(MedalService.class).doMedalBouns(req,this);
	}

}
