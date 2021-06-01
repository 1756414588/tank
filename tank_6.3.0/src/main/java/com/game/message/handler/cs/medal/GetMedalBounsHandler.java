package com.game.message.handler.cs.medal;

import com.game.message.handler.ClientHandler;
import com.game.service.MedalService;


public class GetMedalBounsHandler extends ClientHandler {

	@Override
	public void action() {
		getService(MedalService.class).getMedalBouns(this);
	}

}
