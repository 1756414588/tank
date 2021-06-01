package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.HeroAwakenRq;
import com.game.service.HeroService;

public class HeroAwakenHandler extends ClientHandler {

	@Override
	public void action() {
		HeroAwakenRq req = msg.getExtension(HeroAwakenRq.ext);
		getService(HeroService.class).heroAwaken(req.getHeroId(),this);
	}

}
