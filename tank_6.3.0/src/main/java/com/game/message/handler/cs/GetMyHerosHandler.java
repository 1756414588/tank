package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.HeroService;

public class GetMyHerosHandler extends ClientHandler {

	@Override
	public void action() {
		//Auto-generated method stub
		HeroService heroService = getService(HeroService.class);
		heroService.GetMyHerosRq(this);
	}
}
