package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.LotteryHeroRq;
import com.game.service.HeroService;

public class LotteryHeroHandler extends ClientHandler {

	@Override
	public void action() {
		//Auto-generated method stub
		HeroService heroService = getService(HeroService.class);
		LotteryHeroRq req = msg.getExtension(LotteryHeroRq.ext);
		heroService.LotteryHero(req, this);
	}
}
