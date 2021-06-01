package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.HeroImproveRq;
import com.game.service.HeroService;

public class HeroImproveHandler extends ClientHandler {

	@Override
	public void action() {
		//Auto-generated method stub
		HeroService heroService = getService(HeroService.class);
		HeroImproveRq req = msg.getExtension(HeroImproveRq.ext);
		heroService.heroImprove(req, this);
	}
}
