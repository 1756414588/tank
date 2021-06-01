package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.LockHeroRq;
import com.game.service.HeroService;

public class LockHeroHandler extends ClientHandler {
	
	@Override
	public void action() {
		LockHeroRq req = msg.getExtension(LockHeroRq.ext);
		getService(HeroService.class).lockHero(req, this);
	}

}
