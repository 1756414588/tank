package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.MultiHeroImproveRq;
import com.game.service.HeroService;

public class MultiHeroImproveHandler extends ClientHandler {

	@Override
	public void action() {
		//Auto-generated method stub
		HeroService heroService = getService(HeroService.class);
		MultiHeroImproveRq req = msg.getExtension(MultiHeroImproveRq.ext);
		heroService.multiHeroImproveRq(req, this);
	}
}
