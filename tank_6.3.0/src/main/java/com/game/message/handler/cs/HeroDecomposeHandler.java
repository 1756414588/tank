package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.HeroDecomposeRq;
import com.game.service.HeroService;

public class HeroDecomposeHandler extends ClientHandler {

	@Override
	public void action() {
		//Auto-generated method stub
		HeroService heroService = getService(HeroService.class);
		HeroDecomposeRq req = msg.getExtension(HeroDecomposeRq.ext);
		heroService.heroDecompose(req, this);
	}
}
