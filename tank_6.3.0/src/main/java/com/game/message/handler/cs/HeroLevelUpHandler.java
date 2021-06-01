package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.HeroLevelUpRq;
import com.game.service.HeroService;

public class HeroLevelUpHandler extends ClientHandler {

	@Override
	public void action() {
		//Auto-generated method stub
		HeroService heroService = getService(HeroService.class);
		HeroLevelUpRq req = msg.getExtension(HeroLevelUpRq.ext);
		heroService.heroLevelUp(req, this);
	}
}
